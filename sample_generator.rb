require 'mysql2'

client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "jun_sumida")

client.query("drop table if exists members")
client.query("drop table if exists links")
client.query("drop table if exists footprint_notify")

client.query("
    CREATE TABLE IF NOT EXISTS `members` (
       id int unsigned not null auto_increment,
        name varchar(255) not null,
        sex enum('male', 'female', 'unknown'),
        email varchar(255) not null,
        primary key(`id`),
        KEY idx_name(`name`)
    ) Engine=InnoDB;
")

client.query("
CREATE TABLE IF NOT EXISTS links (
    from_id int unsigned not null,
    to_id int unsigned not null,
    created_at datetime not null,
    primary key(`from_id`, `to_id`),
    KEY idx_to_id(`to_id`)
) Engine=InnoDB;
")

client.query("
    CREATE TABLE IF NOT EXISTS footprint_notify (
        member_id int unsigned not null,
        created_at date not null,
        unreads tinyint unsigned not null,
        count int unsigned not null,
        primary key(`member_id`, `created_at`),
        KEY idx_date(`created_at`)
    ) Engine=InnoDB;
")


def generate_str(length = 10)
    words = ("a".."z").to_a + ("A".."Z").to_a 
    length.times.map{words[rand(words.length + 1)]}.join 
end

def generate_sex
    sex   = ['male', 'female', 'unknown']
    sex[rand(3)] 
end

MAX_OF_MEMBERS = 1000;

1.upto(MAX_OF_MEMBERS).each do
    client.query("
        INSERT INTO members (
            name,
            sex,
            email
        ) VALUES (
            '" + generate_str + "',
            '" + generate_sex + "',
            '" + generate_str + "@" + generate_str(5) + ".com'
        );
    ")
       
    #shud i insert a query for footprint_notify?
end

1.upto(12500).each do
    from_id = rand(MAX_OF_MEMBERS)
    to_id   = rand(MAX_OF_MEMBERS) 

    flag = true
    while flag do
        #p from_id
        #p to_id
        #p "SELECT COUNT(*) FROM links WHERE from_id = " + from_id.to_s + " AND to_id = " + to_id.to_s + ";"
        count = client.query("SELECT COUNT(*) AS count FROM links WHERE from_id = " + from_id.to_s + " AND to_id = " + to_id.to_s + ";").first
        #p count["count"] 
        if from_id != to_id and count["count"] != 1
            flag = false
        else
            from_id = rand(MAX_OF_MEMBERS)
            to_id   = rand(MAX_OF_MEMBERS) 
        end
    end
    
    client.query("
        INSERT INTO links (
            from_id,
            to_id,
            created_at
        ) VALUES (
            " + from_id.to_s + ",
            " + to_id.to_s   + ",
            NOW()
        );
    ")
    client.query("
        INSERT INTO links (
            from_id,
            to_id,
            created_at
        ) VALUES (
            " + to_id.to_s + ",
            " + from_id.to_s   + ",
            NOW()
        );
    ")
end
