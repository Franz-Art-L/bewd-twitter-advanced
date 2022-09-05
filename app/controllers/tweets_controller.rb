class TweetsController < ApplicationController
  def index
    @tweets = Tweet.all.order(created_at: :desc)
    render 'tweets/index'
  end

  def create
    
   if !current_user.rate_limit_passed?
    return render 'tweets/rate_limit_error', status: 400
   end

   @tweet = current_user.tweets.new(tweet_params)

   if @tweet.save
    render 'tweets/create', status: 201
   end
   
  end

  def destroy
    token = cookies.signed[:twitter_session_token]
    session = Session.find_by(token: token)

    return render json: { success: false } unless session

    user = session.user
    tweet = Tweet.find_by(id: params[:id])

    if tweet and tweet.user == user and tweet.destroy
      render json: {
        success: true
      }
    else
      render json: {
        success: false
      }
    end
  end

  def index_by_user
    user = User.find_by(username: params[:username])

    if user
      @tweets = user.tweets
      render 'tweets/index'
    end
  end

  private

    def tweet_params
      params.require(:tweet).permit(:message, :image)
    end
end

# Adding formData property for nested API parameters
# For some API requests, we might need a nested body data structure. Such is the case for the Twitter clone we did in the Ruby on Rails course.

# def tweet_params
# params.require(:tweet).permit(:message, :image)
# end

# js:

# const msg = document.getElementById('message-input');
# const image = document.getElementById('image-select').files[0];
# const formData = new FormData();

# formData.append('tweet[message]', msg);
# formData.append('tweet[image]', image, image.name);

# Note when using fetch requests
# If you are using JavaScript fetch requests to upload a file (image etc.), make sure you don't declare any "Content-Type" and "Accept" property in the fetch options header object. The form data object will handle this automatically.