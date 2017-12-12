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
      :label       => 'function_root',
      :name        => 'Có thể sử dụng toàn bộ các chức năng',
      :description => 'Có thể sử dụng toàn bộ các chức năng',
    )

    FunctionSystem.create(
      :label       => 'user_index',
      :name        => 'Xem danh sách người dùng',
      :description => 'Xem danh sách người dùng',
    )

    create_request_it = FunctionSystem.create(
      :label       => 'create_request_it',
      :name        => 'Tạo công việc',
      :description => 'Tạo công việc',
    )

    FunctionSystem.create(
      :label       => 'own_request_dashboard',
      :name        => 'Xem công việc tôi yêu cầu',
      :description => 'Xem công việc tôi yêu cầu',
      :parent_id   => create_request_it.id
    )

    FunctionSystem.create(
      :label       => 'related_request_dashboard',
      :name        => 'Xem công việc liên quan',
      :description => 'Xem công việc liên quan',
      :parent_id   => create_request_it.id
    )

    FunctionSystem.create(
      :label       => 'assigned_request_dashboard',
      :name        => 'Xem công việc tôi được giao',
      :description => 'Xem công việc tôi được giao',
      :parent_id   => create_request_it.id
    )

    FunctionSystem.create(
      :label       => 'team_dashboard',
      :name        => 'Xem công việc cả nhóm',
      :description => 'Xem công việc cả nhóm',
      :parent_id   => create_request_it.id
    )
  end

  task create_user_function: :environment do
    puts "Create User Function"

    UserFunction.bulk_insert do |worker|
      func = {}
      FunctionSystem.all.each do |f|
        func.merge!("#{f.label}": f)
      end
      # function_root
      # user_index
      # own_request_dashboard
      # related_request_dashboard
      # assigned_request_dashboard
      # team_dashboard

      admin_group = Group.find_by(label: 'admin_group')
      worker.add(
        :function_system_id => func[:user_index].id,
        :group_id           => admin_group.id
      )

      it_hanoi = Group.find_by(label: 'it_hanoi')
      worker.add(
        :function_system_id => func[:own_request_dashboard].id,
        :group_id           => it_hanoi.id
      )
      worker.add(
        :function_system_id => func[:related_request_dashboard].id,
        :group_id           => it_hanoi.id
      )
      worker.add(
        :function_system_id => func[:assigned_request_dashboard].id,
        :group_id           => it_hanoi.id
      )

      it_danang = Group.find_by(label: 'it_danang')
      worker.add(
        :function_system_id => func[:own_request_dashboard].id,
        :group_id           => it_danang.id
      )
      worker.add(
        :function_system_id => func[:related_request_dashboard].id,
        :group_id           => it_danang.id
      )
      worker.add(
        :function_system_id => func[:assigned_request_dashboard].id,
        :group_id           => it_danang.id
      )

      member_group = Group.find_by(label: 'member_group')
      worker.add(
        :function_system_id => func[:own_request_dashboard].id,
        :group_id           => member_group.id
      )
      worker.add(
        :function_system_id => func[:related_request_dashboard].id,
        :group_id           => member_group.id
      )

      # worker.add()
    end
  end

  task create_groups: :environment do
    puts "Create Group and User Group"

    company_group = Group.create(
      :label   => 'company_group',
      :name    => 'Công ty',
      :content => 'Công ty',
    )

    admin_group = Group.create(
      :label     => 'admin_group',
      :name      => 'Nhóm quản trị viên',
      :content   => 'Nhóm quản trị viên',
      :parent_id => company_group.id
    )

    leader_group = Group.create(
      :label     => 'leader_group',
      :name      => 'Nhóm Leader',
      :content   => 'Nhóm Leader',
      :parent_id => company_group.id
    )

    sub_leader_group = Group.create(
      :label     => 'sub_leader_group',
      :name      => 'Nhóm Sub Leader',
      :content   => 'Nhóm Sub Leader',
      :parent_id => company_group.id
    )

    it_hanoi = Group.create(
      :label     => 'it_hanoi',
      :name      => 'Nhóm It Hà Nội',
      :content   => 'Nhóm It Hà Nội',
      :parent_id => company_group.id
    )

    it_danang = Group.create(
      :label     => 'it_danang',
      :name      => 'Nhóm It Đà Nẵng',
      :content   => 'Nhóm It Đà Nẵng',
      :parent_id => company_group.id
    )

    member_group = Group.create(
      :label     => 'member_group',
      :name      => 'Nhóm thành viên hệ thống',
      :content   => 'Nhóm thành viên hệ thống',
      :parent_id => company_group.id
    )

    it_employee  = Group.create(
      :label     => 'it_employee',
      :name      => 'Nhóm thành viên hệ thống',
      :content   => 'Nhóm thành viên hệ thống',
      :parent_id => company_group.id
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
          worker.add(
            :user_id  => employee.id,
            :group_id => it_employee.id,
            :regency  => 'Thành viên'
          )
        elsif index < 16
          worker.add(
            :user_id  => employee.id,
            :group_id => it_danang.id,
            :regency  => 'Thành viên'
          )
          worker.add(
            :user_id  => employee.id,
            :group_id => it_employee.id,
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

  desc "Create fake ticket"
  task create_fake_ticket: :environment do
    member_group  = Group.find_by(label: 'member_group')
    sample_member = User.find_by_sql(%Q|
      select users.id from users
      where
        exists(select 1 from group_users where group_users.group_id = #{member_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    60.times {
      Ticket.create(
        title: Faker::StarWars.quote,
        creator_id: sample_member.id,
        status: rand(0..5)
      )
    }
  end
end
