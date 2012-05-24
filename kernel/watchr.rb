def notify(message)
  growlnotify = `which growlnotify`.chomp
  if !growlnotify.empty?
    system "#{growlnotify} -m \"#{message}\" loganberry-bb"
  end
  notify_send = `which notify-send`.chomp
  unless notify_send.empty?
    system "#{notify_send} -t 100 'loagnberry-bb' '#{message}'"
  end
end

system("rake kernel:spec")

watch('^(app|spec)') do
  system("rake kernel:spec")
  notify ($?.success? ? "Build successful!" : "Build failed :(")
end
