module SampleUserHelper
    # get sample users method
  def get_sample_users
    leader_group                = Group.find_by(label: 'leader_group')
    sub_leader_group            = Group.find_by(label: 'sub_leader_group')
    it_hanoi                    = Group.find_by(label: 'it_hanoi')
    it_danang                   = Group.find_by(label: 'it_danang')
    member_group                = Group.find_by(label: 'member_group')
    it_employee                 = Group.find_by(label: 'it_employee')

    @sample_admin               = Admin.select('username').first
    @sample_it_hanoi_leader     = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_hanoi.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{leader_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_it_danang_leader     = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_danang.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{leader_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_it_hanoi_sub_leader  = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_hanoi.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{sub_leader_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_it_danang_sub_leader = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_danang.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{sub_leader_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_it_hanoi_employee    = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_hanoi.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{it_employee.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_it_danang_employee   = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{it_danang.id} and group_users.user_id = users.id)
          and
        exists(select 1 from group_users where group_users.group_id = #{it_employee.id} and group_users.user_id = users.id)
      limit 1;
    |).first

    @sample_member               = User.find_by_sql(%Q|
      select users.username from users
      where
        exists(select 1 from group_users where group_users.group_id = #{member_group.id} and group_users.user_id = users.id)
      limit 1;
    |).first
  end
end
