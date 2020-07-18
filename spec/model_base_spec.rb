require 'rspec'
require_relative '../model_base'
require_relative '../question_follow'
require_relative '../reply'
require_relative '../question_like'

describe ModelBase do
    before(:each) { QuestionsDatabase.reset! }
    after(:each) { QuestionsDatabase.reset! }

    describe '::find_by_id' do
        it 'correctly formats table names for multiple classes' do
            expect(QuestionFollow.table).to eq('question_follows')
            expect(QuestionLike.table).to eq('question_likes')
        end
    end

    describe '::all' do
        it 'returns an array of object items for a class' do
            all_users = User.all
            expect(all_users).to all(be_an(User))
        end

        it 'returns all object items in the database' do
            all_questions = Question.all
            expect(all_questions.count).to eq(3)
        end

        context 'when called on different classes' do
            it 'returns all replies' do
                all_replies = Reply.all
                expect(all_replies).to all(be_an(Reply))
            end

            it 'returns all questions' do
                all_questions = Question.all
                expect(all_questions).to all(be_an(Question))
            end
        end
    end

    describe '::where' do
        it 'searches for table column based on method name' do
            search1 = User.where("fname" => "Rocky")
            expect(search1.first).to be_an(User)
            expect(search1.first.fname).to eq("Rocky")
        end

        context 'when called on different classes' do
            it 'filters replies based on parameters' do
                search1 = Reply.where("body" => "Did you say NOW NOW NOW?")
                expect(search1.first).to be_an(Reply)
            end

            it 'filters questions bases on parameters' do
                search2 = Question.where("title" => "Rocky Question")
                expect(search2.first).to be_an(Question)
            end
        end
    end

    describe '::find_by' do
        it 'searches fot the first name of a user' do
            search1 = User.find_by(fname: "Rocky")
            expect(search1.first).to be_an(User)
            expect(search1.first.fname).to eq("Rocky")
            expect(search1.count).to eq(1)
        end

        it 'searches for the body of a reply' do
            reply = Reply.find_by(body: "Did you say NOW NOW NOW?")
            expect(reply.first).to be_an(Reply)
            expect(reply.first.body).to eq("Did you say NOW NOW NOW?")
        end

        it 'searches for the title of a question' do
            question = Question.find_by(title: "Rocky Question")
            expect(question.first).to be_an(Question)
            expect(question.first.title).to eq("Rocky Question")
        end
    end
end