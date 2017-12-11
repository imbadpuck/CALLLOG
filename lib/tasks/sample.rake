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

    FunctionSystem.create(
      :label       => 'all',
      :name        => 'Có thể sử dụng toàn bộ các chức năng',
      :description => 'Có thể sử dụng toàn bộ các chức năng',
    )

    FunctionSystem.create(
      :label       => 'users/index',
      :name        => 'Xem danh sách người dùng',
      :description => 'Xem danh sách người dùng',
    )
  end

  task create_user_function: :environment do
    puts "Create User Function"

    UserFunction.bulk_insert do |worker|
      function_root = FunctionSystem.find_by(label: 'all')
      admin_group   = Group.find_by(label: 'admin_group')
      worker.add(
        :function_id => function_root.id,
        :group_id    => admin_group.id
      )
    end
  end

  task create_groups: :environment do
    puts "Create Group and User Group"

    admin_group = Group.create(
      :label   => 'admin_group',
      :name    => 'Nhóm quản trị viên',
      :content => 'Nhóm quản trị viên',
    )

    leader_group = Group.create(
      :label   => 'leader_group',
      :name    => 'Nhóm Leader',
      :content => 'Nhóm Leader',
    )

    sub_leader_group = Group.create(
      :label   => 'sub_leader_group',
      :name    => 'Nhóm Sub Leader',
      :content => 'Nhóm Sub Leader',
    )

    it_hanoi = Group.create(
      :label   => 'it_hanoi',
      :name    => 'Nhóm It Hà Nội',
      :content => 'Nhóm It Hà Nội',
    )

    it_danang = Group.create(
      :label   => 'it_danang',
      :name    => 'Nhóm It Đà Nẵng',
      :content => 'Nhóm It Đà Nẵng',
    )

    member_group = Group.create(
      :label   => 'member_group',
      :name    => 'Nhóm thành viên hệ thống',
      :content => 'Nhóm thành viên hệ thống',
    )

    GroupUser.bulk_insert do |worker|
      Admin.all.each_with_index do |admin, index|
        if index == 0
          worker.add(
            :user_id  => admin.id,
            :group_id => admin_group.id,
            :regency  => 'Trưởng nhóm'
          )
        else
          worker.add(
            :user_id  => admin.id,
            :group_id => admin_group.id,
            :regency  => 'Thành viên'
          )
        end
      end

      Employee.all.each_with_index do |employee, index|
        if index == 0
          worker.add(
            :user_id  => employee.id,
            :group_id => leader_group.id,
            :regency  => 'Trưởng nhóm'
          )
          worker.add(
            :user_id  => employee.id,
            :group_id => it_hanoi.id,
            :regency  => 'Trưởng nhóm'
          )
        elsif index == 1
          worker.add(
            :user_id  => employee.id,
            :group_id => leader_group.id,
            :regency  => 'Thành viên'
          )
          worker.add(
            :user_id  => employee.id,
            :group_id => it_danang.id,
            :regency  => 'Trưởng nhóm'
          )
        elsif index == 2
          worker.add(
            :user_id  => employee.id,
            :group_id => sub_leader_group.id,
            :regency  => 'Trưởng nhóm'
          )
          worker.add(
            :user_id  => employee.id,
            :group_id => it_hanoi.id,
            :regency  => 'Phó nhóm'
          )
         elsif index == 3
          worker.add(
            :user_id  => employee.id,
            :group_id => sub_leader_group.id,
            :regency  => 'Thành viên'
          )
          worker.add(
            :user_id  => employee.id,
            :group_id => it_danang.id,
            :regency  => 'Phó nhóm'
          )
        elsif index < 10
          worker.add(
            :user_id  => employee.id,
            :group_id => it_hanoi.id,
            :regency  => 'Thành viên'
          )
        elsif index < 16
          worker.add(
            :user_id  => employee.id,
            :group_id => it_danang.id,
            :regency  => 'Thành viên'
          )
        else
          worker.add(
            :user_id  => employee.id,
            :group_id => member_group.id,
            :regency  => 'Thành viên'
          )
        end
      end
    end
  end
end
