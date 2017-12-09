namespace :sample do
  task create_users: :environment do
    puts "Create Admin"

    5.times do |i|
      Admin.create(
        :username  => "Admin_" + i.to_s,
        :name      => Faker::Name.name,
        :code      => "Admin_#{Faker::Code.ean + i.to_s}",
        :birthdate => Faker::Date.birthday(18, 50),
        :gender    => rand(0..2),
        :phone     => Faker::PhoneNumber.phone_number.gsub(/\s/, ""),
        :email     => Faker::Internet.email,
        :password  => "12345678",
      )
    end

    puts "Create Employees"
    100.times do |i|
      Employee.create(
        :username  => "NV_" + i.to_s,
        :name      => Faker::Name.name,
        :code      => "NV_#{Faker::Code.ean}",
        :birthdate => Faker::Date.birthday(18, 50),
        :gender    => rand(0..2),
        :phone     => Faker::PhoneNumber.phone_number.gsub(/\s/, ""),
        :email     => Faker::Internet.email,
        :password  => "12345678",
      )
    end
  end

  task create_functions: :environment do
    puts "Create Function"

    FunctionSystem.bulk_insert do |worker|
      worker.add(
        :label       => 'users/index',
        :name        => 'Xem danh sách người dùng',
        :description => 'Xem danh sách người dùng',
      )
    end
  end
end
