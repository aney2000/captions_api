FactoryBot.define do
  factory :caption do
    url { "http://example.com/a.jpg" }
    text { "caption text" }
    caption_url { "http://localhost/images/a.jpg" }
  end
end
