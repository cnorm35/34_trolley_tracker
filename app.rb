require 'sinatra'
require 'net/http'
require 'json'

#TODO: show trolley direction


get '/' do
  @data = parse_data(trolley_data)
  @trolley_coords = trolley_coords(@data)
  @service_alert = service_alert?
  @alert_message = alert_message
  @advisory_message = advisory_message
  @detour_reason = detour_reason
  @alert_last_updated = alert_last_updated
  erb :index
end


def trolley_data
 send_request('http://www3.septa.org/beta/TransitView/34')
end

def parse_data(data)
  JSON.parse(data)
end

def trolley_coords(data)
 data["bus"].map {|bus| [bus["lat"], bus['lng']]}
end

def send_request(url)
  url = URI.parse(url.to_s)
  req = Net::HTTP::Get.new(url)
  res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
  res.body
end

def alerts
  alerts = send_request(
    'http://www3.septa.org/hackathon/Alerts/get_alert_data.php?req1=trolley_route_34'
  )
  JSON.parse(alerts)
end

def service_alert?
  if alerts.first['current_message'].empty?
    false
  else
    true
  end
end

def alert_message
  alerts.first['current_message']
end

def advisory_message
  alerts.first['advisory_message']
end

def detour_reason
  alerts.first['detour_reason']
end

def alert_last_updated
  alerts.first['last_updated']
end
