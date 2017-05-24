require 'csv'

class LearningPath
  attr_reader :domain_order_filename, :student_tests_filename

  def initialize(args)
    @domain_order_filename = args[:domain_order]
    @student_tests_filename = args[:student_tests]
  end

  # Return one-dimensional array of full learning pathway order
  def full_pathway
    return @full_pathway if @full_pathway
    domain_order = CSV.read(domain_order_filename)

    # Format the domain levels as <grade_level>.<domain>, e.g. 'K.RF'
    formatted_levels = domain_order.map.with_index do |level_order, idx|
      grade_level = idx == 0 ? 'K' : idx.to_s

      level_order.drop(1).map! do |domain|
        "#{grade_level}.#{domain}"
      end
    end

    @full_pathway = formatted_levels.flatten
  end

  # Output learning_paths.csv with all student learning paths
  def output_csv_for_all(filename)
    CSV.open(filename, 'w') do |csv|
      students.each do |student|
        csv << student_path(student).unshift(student)
      end
    end
  end

  # Get learning pathway for single student
  def student_path(student)
    full_pathway.each_with_object([]) do |domain_level, path|
      next if path.length == 5
      level, domain = domain_level.split('.')
      student_level = student_tests[student][domain]
      if normalize_compare_levels(level, student_level) > -1
        path << domain_level
      end
    end
  end

  # Return hash of students where keys are student names and values are hashes of
  # their test scores
  # Ex. { 'Student Name' => { 'RF' => 'K', 'RL' => '1', 'RI' => '1', 'L' => 'K' }
  def student_tests
    return @student_tests if @student_tests
    student_tests = CSV.read(student_tests_filename).drop(1)
    student_tests.map! do |student|
      domain_levels = student_tests_headers.zip(student.drop(1)).to_h
      [student.first, domain_levels]
    end

    @student_tests = student_tests.to_h
  end

  # Return array of student names
  def students
    @students ||= student_tests.keys
  end

  private

  # Normalize levels (i.e. 'K' = 0) before comparing
  def normalize_compare_levels(a, b)
    a = a == 'K' ? 0 : a.to_i
    b = b == 'K' ? 0 : b.to_i

    a <=> b
  end

  # Return domain headers from student_tests CSV
  def student_tests_headers
    @student_tests_headers ||=
      CSV.open(student_tests_filename) { |csv| csv.first.drop(1) }
  end
end
