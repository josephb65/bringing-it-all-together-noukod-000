class Dog
  attr_accessor :id, :name, :breed
  def initialize(id:nil, name:, breed:)
    self.id = id
    self.name = name
    self.breed = breed
  end


  def self.create_table
    sql = <<-SQL
      create table if not exists dogs (
          id Integer primary key,
          name text,
          breed text
      )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      drop table if exists dogs
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs").flatten.first
    end
    self
  end

  def self.create(name:, breed:)
    tdog = self.new(name:name, breed: breed)
    tdog.save
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed:row[2])
  end

  def self.find_by_id(id)
    sql = <<-SQL
        select * from dogs where id = ?
    SQL

    DB[:conn].execute(sql, id).map do |d|
      self.new_from_db(d)
    end.first
  end

  def self.find_by_name(name)
    sql = <<-SQL
        select * from dogs where name = ?
    SQL

    DB[:conn].execute(sql, name).map do |d|
      self.new_from_db(d)
    end.first
  end

  def self.find_or_create_by(name:, breed:)
    fdog = DB[:conn].execute("Select * from dogs WHERE name = ? and breed = ?", name, breed)
    if !fdog.empty?
      find_dog = fdog.first
      fdog = self.new(id:find_dog[0], name:find_dog[1], breed:find_dog[2])
    else
      fdog = self.create(name: name, breed: breed)
    end
    fdog
  end

  def update
    sql = <<-SQL
      update dogs set name = ?, breed = ? where id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end