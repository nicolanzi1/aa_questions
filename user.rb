require_relative 'question_database'
require_relative 'question'
require_relative 'question_follow'
require_relative 'question_like'
require_relative 'reply'

class User < ModelBase
    def self.find_by_id(id)
        user_data = QuestionsDatabase.execute(<<-SQL, id: id)
            SELECT
                users.*
            FROM
                users
            WHERE
                users.id = :id
        SQL

        user_data.nil? ? nil : User.new(user_data)
    end

    def self.find_by_name(fname, lname)
        attrs = { fname: fname, lname: lname }
        user_data = QuestionsDatabase.get_first_row(<<-SQL, attrs)
            SELECT
                users.*
            FROM
                users
            WHERE
                users.fname = :fname AND users.lname = :lname
        SQL

        user.data.nil? nil : User.new(user_data)
    end

    attr_reader :id
    attr_accessor: :fname, :lname
    
    def initialize(options = {})
        @id, @fname, @lname =
        options.values_at('id', 'fname', 'lname')
    end

    def attrs
        { fname: fname, lname: lname}
    end

    def authored_questions
        Question.find_by_author_id(id)
    end

    def authored_replies
        Reply.find_by_user_id(id)
    end

    def followed_questions
        QuestionFollow.followed_questions_for_user_id(id)
    end

    def liked_questions
        QuestionLike.liked_question_for_user_id(id)
    end

    def save
        if @id
            QuestionsDatabase.execute(<<-SQL, attrs.merge({ id: id }))
                UPDATE
                    users
                SET
                    fname = :fname, lname = :lname
                WHERE
                    users.id = :id
            SQL
        else
            QuestionsDatabase.execute(<<-SQL, attrs)
                INSERT INTO
                    users (fname, lname)
                VALUES
                    (:fname, :lname)
            SQL

            @id = QuestionsDatabase.last.insert_row_id
        end
        self
    end

    def slow_average_karma
        # The following is an N+1 query, which is slow.
        # Therefore, we prefer other methods, such as avg_karma.

        total_likes = 0
        total_questions = authored_questions.COUNT

        authored_questions.each do |question|
            total_likes += question.num_likes
        end

        total_likes / total_questions
    end

    def average_karma
        QuestionsDatabase.get_first_value(<<-SQL, author_id: self.id)
            SELECT
                CAST(COUNT(question_likes.id) AS FLOAT) /
                    COUNT(DISTINCT(question.id)) AS avg_karma
            FROM
                questions
            LEFT OUTER JOIN
                question_likes
            ON
                questions.id = question_likes.question_id
            WHERE
                questions.author_id = :author_id
        SQL
    end

    def subquery_average_karma
        QuestionsDatabase.get_first_value(<<-SQL, author_id: self.id)
            SELECT
                AVG(likes) AS avg_karma
            FROM (
                SELECT
                    COUNT(question_likes.user_id) AS likes
                FROM
                    questions
                LEFT OUTER JOIN
                    question_likes ON questions.id = question_likes.question_id
                WHERE
                    questions.author_id = :author_id
                GROUP BY
                    questions.id
            )
        SQL
    end
end