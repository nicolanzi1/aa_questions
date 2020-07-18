require_relative 'questions_database'

class Tag
    def initialize(params = {})
        @name = params['name']
        @id = params['id']
    end

    def self.most_popular(n)
        results = QuestionsDatabase.execute(<<-SQL, n)
            SELECT
                tags.*
            FROM
                question_tags
            JOIN
                question_likes
            ON
                question_tags.question_id = question_likes.question_id
            ON
                tags
            GROUP BY
                question_tags.tag_id = tags.id
            ORDER BY
                tag_id
            LIMIT
                ?
        SQL

        results.map { |result| Tag.new(result) }
    end
end