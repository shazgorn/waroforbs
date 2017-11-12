module TimeHelper
  def seconds_to_hm t
    minutes = (t / 60).round(0)
    seconds = t % 60
    if seconds < 10
      seconds = "0#{seconds}"
    end
    "#{minutes}:#{seconds}"
  end

  def hm_to_seconds hm
    hm_arr = hm.split(':')
    minutes = hm_arr[0].to_i
    seconds = hm_arr[1].to_i
    minutes * 60 + seconds
  end
end
