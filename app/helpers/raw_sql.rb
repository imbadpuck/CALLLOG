module RawSql
  def self.convert_result_to_hash(result)
    result_array  = result.to_a
    result_fields = result.fields
    last_result   = []
    result_array.each do |r|
      hash = {}
      r.each_with_index do |value, index|
        hash.merge!({"#{result_fields[index]}": value})
      end
      last_result << hash
    end
    return last_result
  end
end
