require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  def initialize(name ,grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.db_execute(sql)
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE students(
        id INTEGER PRIMARY KEY,
        name TEXT,
        grade INTEGER
      );
    SQL

    self.db_execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE students;
    SQL

    self.db_execute(sql)
  end

  def save
    if self.id == nil
      sql = <<-SQL
        INSERT INTO students (name,grade) VALUES(?,?);
      SQL


      DB[:conn].execute(sql,self.name,self.grade)

      sql = <<-SQL
        SELECT last_insert_rowid() FROM students
      SQL

      last_id  = self.class.db_execute(sql)[0][0]
      self.id = last_id
    else
      self.update
    end
  end

  def self.create(name,grade)
    sql = <<-SQL
      INSERT INTO students(name,grade) VALUES(?,?);
    SQL
    DB[:conn].execute(sql,name,grade)
  end

  def self.new_from_db(row)
    new_student = Student.new(row[1],row[2])
    new_student.id = row[0]
    new_student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students where name = ?;
    SQL

    self.new_from_db(DB[:conn].execute(sql,name)[0])

  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE id = ?;
    SQL
    DB[:conn].execute(sql,self.name,self.grade,self.id)
  end

end
