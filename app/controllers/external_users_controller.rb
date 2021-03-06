class ExternalUsersController < ApplicationController
  def authorize!
    authorize(@user || @users)
  end
  private :authorize!

  def index
    @users = ExternalUser.all.includes(:consumer).paginate(page: params[:page])
    authorize!
  end

  def show
    @user = ExternalUser.find(params[:id])
    authorize!
  end

  def working_time_query
    """
    SELECT user_id,
           exercise_id,
           max(score) as maximum_score,
           count(id) as runs,
           sum(working_time_new) AS working_time
    FROM
      (SELECT user_id,
              exercise_id,
              score,
              id,
              CASE
                  WHEN working_time >= '0:30:00' THEN '0'
                  ELSE working_time
              END AS working_time_new
       FROM
         (SELECT user_id,
                 exercise_id,
                 max(score) AS score,
                 id,
                 (created_at - lag(created_at) over (PARTITION BY user_id, exercise_id
                                                     ORDER BY created_at)) AS working_time
          FROM submissions
          WHERE user_id = #{@user.id}
            AND user_type = 'ExternalUser'
          GROUP BY exercise_id,
                   user_id,
                   id) AS foo) AS bar
    GROUP BY user_id,
             exercise_id;
    """
  end

  def statistics
    @user = ExternalUser.find(params[:id])
    authorize!

    statistics = {}

    ActiveRecord::Base.connection.execute(working_time_query).each do |tuple|
      statistics[tuple["exercise_id"].to_i] = tuple
    end

    render locals: {
      statistics: statistics
    }
  end

end
