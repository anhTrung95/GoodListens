class ReviewsController < ApplicationController
  before_action :find_review, except: %i(new create index)
  before_action :find_song, except: %i(create index show)

  attr_reader :review, :song

  def show
    @like = Like.find_by(user_id: current_user.id, review_id: @review.id)
    @comments = @review.comments.all
    @comment = @review.comments.build
  end

  def new
    @review = Review.new
  end

  def create
    @review = Review.new review_params
  	if @review.save
      @song = Song.find(review_params[:song_id])
      song.update_attributes(rate_avg: 
        ((song.sum_rate * song.rate_avg + @review.rate_score)/(song.sum_rate + 1)),
          sum_rate: (song.sum_rate + 1))
      redirect_to song
      flash[:success] = "Create review successfully"
    else
      redirect_to :back
  	end
  end

  def edit; end

  def update
    if review.update_attributes review_params
      redirect_to song
      flash[:success] = "Update review successfully"
    else
      redirect_to :back
    end
  end

  def destroy
    if @review.destroy
      flash[:success] = "Delete review successfully"
    else
      flash[:danger] = "Delete review unsuccessfully"
    end
    redirect_to @song
  end

  private

  def review_params
    params.require(:review).permit(Review::CREATE_PARAMS)
  end

  def find_song
    @song = Song.find_by id: params[:song_id]
    song = Song.find_by id: params[:id] unless song 
  end

  def find_review
    @review = Review.find_by id: params[:id]
    render_not_found unless @review
  end
end
