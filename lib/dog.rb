class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL
       
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(attributes)
        Dog.new(attributes).tap do |dog|
            dog.save
        end
    end

    def self.new_from_db(attributes)
        hash = {id: attributes[0],
        name: attributes[1],
        breed: attributes[2]}
        Dog.new(hash)
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        data = DB[:conn].execute(sql, id)[0]

        hash = {
            id: data[0],
            name: data[1],
            breed: data[2]
        }
        Dog.new(hash)
    end

    def self.find_or_create_by(attributes)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL
        data = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
        if !data
            self.create(attributes)
        else
            self.new_from_db(data)
        end
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL
        
        self.new_from_db(DB[:conn].execute(sql,name)[0])
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ?
            WHERE id = ?
        SQL

        DB[:conn].execute(sql, name, breed, id)
    end

end