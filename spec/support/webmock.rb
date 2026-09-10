require "webmock/rspec"

# Disable all real HTTP connections during tests. Image downloads and any
# external calls must be stubbed explicitly in the relevant spec.
WebMock.disable_net_connect!(allow_localhost: true)
