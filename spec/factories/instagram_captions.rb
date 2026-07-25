FactoryBot.define do
  factory :instagram_caption do
    url { "http://example.com/a.jpg" }
    text { "caption text" }
    type_name { "image" }
    filter { nil }
    caption_url { "http://localhost/images/a.jpg" }
  end
end
