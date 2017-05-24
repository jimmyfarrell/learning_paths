require File.join(File.dirname(__FILE__), 'learning_path')

filenames = {
  domain_order: File.join(File.dirname(__FILE__), 'data', 'domain_order.csv'),
  student_tests: File.join(File.dirname(__FILE__), 'data', 'student_tests.csv')
}
learning_paths = LearningPath.new(filenames)
learning_paths.output_csv_for_all('learning_paths.csv')
