require 'factual'
require 'lazy_high_charts'
require 'json'

class RestaurantController < ApplicationController
  before_filter :require_user
  #rows per page in query
  ROW_COUNT = 50 
  @@gxAxis = {'cuisine' => 'Cuisine Types','address' => 'Location by Road','rating' => 'Average Number of Stars','price' => 'Pricing Range' }

  def index
    #get data from factual.com
    query_factual
    
    #visualizes query in different categories
    create_graph
  
  end
  
  def order
    
    @count = 1
    @list = []
    
    if params[:id] != nil && params[:category] != nil
      @selected = params[:id]
      @cur_cat = @@gxAxis.select{|k,v| v == params[:category] }.first.first
    end
    
    query_factual
    extractallpages(@cur_cat, true)
    
    @list = @list.uniq
    @list = @list.paginate(:page => params[:page], :per_page => 15)
  
 end
 
 def processing
  @selected_restaurant = eval(params[:restaurant_id])
  @user = current_user
  
 end
 
 def range
   
   #@list = []
   
   #query_factual
   #@query = @query.select(:name, :address)
   #extractallpages(nil, true)
   
   
 end
  
  private
  
  def query_factual
    
    #factual api query call for rocherster hills, mi with no delivery
    factual = Factual.new("oDzUB7JRjHoE3GcH84b9Y9ymxEL3M59dlqzwvuYg", "WhsHS2otjOdxryWT2OhdZMPptZpEhHOXfuCWU4Dl")
    @query = factual.table("restaurants").filters( :country => "us", :region => "mi", :locality => "rochester hills", :meal_deliver => false)
    @query = @query.select(:name, :address, :cuisine, :price, :rating ) 
    
    #data structure values
    @page_count = ( Float(@query.total_count) / Float(ROW_COUNT) ).ceil
    @rows_last_page = @query.total_count -  (@page_count - 1) * ROW_COUNT
    
  end
  
  def create_graph
    
    @hData = {} #hash for extracted query data
    
    #chart titles and labels
    gTitle = {'cuisine' => 'Restaurant Cuisine Types','address' => 'Restaurant Locations in Rochester Hills','rating' => 'Restaurant Star Rating','price' => 'Restaurant Average Meal Price' }
   
    
    extractallpages(params[:graph_categories])
    
    #orginizes data alphabetically or numberically
    gData = @hData.sort_by {|key, value| key }
    @hGraph = LazyHighCharts::HighChart.new('column') do |f|
    
    #set data and names data in graph
    gData.each do |key, value|
      f.series(:name=>key ,:data=> [value])
    end
    
        
    #chart options
    f.title({ :text=> gTitle[params[:graph_categories] ] })  
    f.options[:chart][:defaultSeriesType] = "column"
    f.options[:plotOptions][:series] = {:minPointLength => 9} 
    f.options[:plotOptions][:column] = { :cursor => 'pointer', :point => {:events => {:click => 'js_function'}}}
    #f.options[:chart][:height] = 600;
    #f.options[:chart][:width] = 800;
    
    #legend options
    f.options[:legend][:layout] = "horizontal"
    
    #xAxis options
    f.options[:xAxis][:title] = {:text => @@gxAxis[params[:graph_categories]] }
    f.options[:xAxis][:labels] = {:enabled => false }
    f.options[:xAxis][:minorTickLength] = 0
    f.options[:xAxis][:tickLength] = 0
    
    #yAxis Options
    f.options[:yAxis][:title] = {:text => 'Number of Restaurants' }
    f.options[:yAxis][:allowDecimals] = false
    
    
    end
    
  end #create_graph
  
  def extractallpages(category, byrow = false)
  
  
    for page in 1..@page_count
      if page < @page_count
        @query = @query.page(page, :per => ROW_COUNT)
        if(byrow == false)
          extractdataby(category, false)
        else
          extractrowsby(category, false)
        end
      else
        @query = @query.page(page, :per => @rows_last_page)

        if(byrow == false)
          extractdataby(category, true)
        else
          extractrowsby(category, true)
        end

      end
    end
    
  end #extractallpages
  
   def extractdataby(category, islastpage)

    #apply default category if no category is given
    if category == nil
      params[:graph_categories] = category = 'cuisine'
    end
    
    #determines if the query is on the last page
    #and how many rows should be cycled through
    if islastpage == true
      row_count = @rows_last_page - 1
    else
      row_count = ROW_COUNT - 1
    end
  
  
      for entry in 0..row_count do
      data = []
      
      if @query[entry][category] != nil
       
       #determine how to extract data and format accordingly
        if category == 'cuisine'
           @query[entry][category].each do |str|
             data.push str
           end
    
        else
          data.push @query[entry][category].to_s
        
            if category == 'price'

            data.each do |d|
              case d
              when "1" then d.replace '$0-15'
              when "2" then d.replace '$15-30'
              when "3" then d.replace '$30-50'
              when "4" then d.replace '$50-75'
              when "5" then d.replace  '$75+'
              end
            end

          elsif category == 'address'

            data.each do |d|
              d.gsub!(/^\d*/, '')
            end

          end #end if
        
        end
      end #check nil
   

      #creates main hash table for graphing data
      data.each do |d|
        if @hData.has_key? d
        @hData[d.to_s] = @hData[d.to_s] + 1
        else
          @hData.merge!( {d.to_s => 1} )
        end
      end

    end #query

  end #sortdataby
 
  def extractrowsby(category, islastpage)
    
    if islastpage == true
      row_count = @rows_last_page - 1
    else
      row_count = ROW_COUNT - 2
    end
  
    for entry in 0..row_count do
    
      if(category == nil)
        @list.push @query[entry]
      else
        if(category == 'cuisine')
          if(@query[entry][category].include? @selected)
            @list.push @query[entry]
          end
        elsif (category == 'address')
          if(@query[entry][category].to_s.include? @selected )
            @list.push @query[entry]
          end
        elsif (category == 'rating')
          if(@query[entry][category].to_s == @selected )
            @list.push @query[entry]
          end
        elsif (category == 'price')
          
          if(@query[entry][category] == money_to_price_index(@selected))
            @list.push @query[entry]
          end
        end
      end
    end
    
  end #rowsby 
 
   def money_to_price_index(money)
    if money == "$0-15" 
      return 1
    elsif money == "$15-30"
      return  2
    elsif money == "$30-50"
      return  3
    elsif money == "$50-75"
      return  4
    elsif money == "$75+"
      return  5
    end
  end
 
end
