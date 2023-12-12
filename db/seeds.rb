# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


case Rails.env
when "development"
    %w[
      https://stackoverflow.com/questions/5456020/sha1-hashing-in-rails
      https://www.nyc.gov
      ]
      .each do |external_url|
        LinkEntry.find_or_create_by!(external_url: external_url)
    end
when "production"
  File.open(Rails.root.join('storage', 'short_ids.txt'), "w+") do |f|
    (0...10000).each do |index|
      link_entry = LinkEntry.find_or_create_by!(external_url: "http://example.com/link_#{index}")
      f.puts link_entry.short_id
    end
  end
else
  puts "No op"
end
