require 'csv'
require 'minitest/autorun'
require File.join('.', File.dirname(__FILE__), '..', 'learning_path')

describe LearningPath do
  before do
    filenames = {
      domain_order: File.join('.', File.dirname(__FILE__), 'data', 'domain_order_test.csv'),
      student_tests: File.join('.', File.dirname(__FILE__), 'data', 'student_tests_test.csv')
    }
    @learning_path = LearningPath.new(filenames)
  end

  describe '#full_pathway' do
    it 'returns an array of the full formatted learning pathway' do
      full_pathway = %w(K.A K.B K.C 1.A 1.B 1.C 1.D 2.C 2.B 2.A 2.D 3.D 3.C)
      @learning_path.full_pathway.must_equal(full_pathway)
    end
  end

  describe '#output_csv_for_all' do
    after do
      File.delete('test.csv')
    end

    it 'takes a filename and writes a CSV file with all student learning pathways' do
      pathways = [
        ['First One', 'K.A', 'K.B', 'K.C', '1.A', '1.B'],
        ['Second Two', 'K.B', 'K.C', '1.B', '1.C', '1.D'],
        ['Third Three', '2.D', '3.D', '3.C'],
        ['Fourth Four', 'K.B', '1.A', '1.B', '1.D', '2.C'],
        ['Fifth Five', '1.A', '1.D', '2.C', '2.B', '2.A']
      ]
      @learning_path.output_csv_for_all('test.csv')
      CSV.read('test.csv').must_equal(pathways)
    end
  end

  describe '#student_path' do
    it 'accepts a student name and returns an array of formatted domain levels' do
      domain_levels = %w(2.D 3.D 3.C)
      @learning_path.student_path('Third Three').must_equal(domain_levels)
    end

    it "includes domain levels at or higher than student's tested level" do
      @learning_path.student_path('Fourth Four').must_include('1.A')
      @learning_path.student_path('Fourth Four').must_include('1.B')
    end

    it "does not include domain levels lower than student's tested level" do
      @learning_path.student_path('Fourth Four').wont_include('K.C')
      @learning_path.student_path('Fourth Four').wont_include('1.C')
    end

    it 'returns an array of max size 5' do
      @learning_path.student_path('First One').length.must_equal(5)
    end
  end

  describe '#student_tests' do
    it 'returns a hash with student names as keys' do
      student_names = ['First One', 'Second Two', 'Third Three', 'Fourth Four', 'Fifth Five']
      @learning_path.student_tests.keys.must_equal(student_names)
    end

    it 'returns a hash with values that are hashes with keys of domains' do
      domains = %w(A B C D)
      @learning_path.student_tests.values.each do |student_levels|
        student_levels.keys.must_equal(domains)
      end
    end

    it 'returns a hash with values that are hashes with values of grade levels' do
      grade_levels = %w(K 1 2 3)
      @learning_path.student_tests.values.each do |student_levels|
        student_levels.values.each { |level| grade_levels.must_include(level) }
      end
    end

    it "returns a hash that represents each student's test results" do
      test_results = { 'A' => '2', 'B' => 'K', 'C' => 'K', 'D' => 'K' }
      @learning_path.student_tests['Second Two'].must_equal(test_results)
    end
  end

  describe '#students' do
    it 'returns an array of all students with test scores' do
      students = ['First One', 'Second Two', 'Third Three', 'Fourth Four', 'Fifth Five']
      @learning_path.students.must_equal(students)
    end
  end
end
