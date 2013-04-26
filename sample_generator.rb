require 'mysql2'

client = Mysql2::Client.new(:host => "dev.mysql.lo.mixi.jp", :username => "root", :database => "jun_sumida")

result = client.query("SELECT * FROM entry;");

result.each do |entry|
    p entry
end
