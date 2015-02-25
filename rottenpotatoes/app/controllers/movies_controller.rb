# The controller for movies
class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  def index
    @all_ratings = Movie.all_ratings
    redirect = sort_changed || ratings_changed
    set_session_sort
    set_session_ratings
    if redirect
      flash.keep
      redirect_to sort: session[:sort], ratings: session[:ratings]
    else
      movies_by_rating_and_order
    end
  end

  private

  def movies_by_rating_and_order
    @movies = Movie.find_all_by_rating(@selected_ratings.keys,
                                       order: session[:sort])
  end

  def sort_changed
    params[:sort] != session[:sort]
  end

  def set_session_sort
    session[:sort] = params[:sort] || session[:sort]
    case session[:sort]
    when 'title'
      @title_header = 'hilite'
    when 'release_date'
      @date_header = 'hilite'
    end
  end

  def ratings_changed
    (params[:ratings] != session[:ratings])
  end

  def set_session_ratings
    session[:ratings] = params[:ratings] || session[:ratings] 
    @selected_ratings = session[:ratings] || default_ratings
  end

  def default_ratings
    Hash[@all_ratings.map { |rating| [rating, rating] }]
  end
end
