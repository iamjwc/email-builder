require 'digest/sha1'

class EmailBuilder
  attr_accessor :to, :from, :cc, :bcc, :subject, :body, :body_content_type
  attr_reader   :attachments

  TYPES = {
    :html  => "text/html",
    :plain => "text/plain"
  }

  def initialize(opts)
    @attachments = []
    @body_content_type = :html

    opts.each do |k, v|
      self.send("#{k}=", v)
    end
  end

  def attachments?
    @attachments.size != 0
  end

  def attach(hash)
    @attachments << hash
  end

  def to_s
    message = <<-EMAIL
From: #{from}
To: #{to}
CC: #{cc}
BCC: #{bcc}
Subject: #{subject}
Date: #{Time.now.rfc2822}
MIME-Version: 1.0
    EMAIL
    
    if attachments?
      message += <<-EMAIL
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
Content-Transfer-Encoding: 8bit
      EMAIL
    end

    message += <<-EMAIL
Content-Type: #{TYPES[body_content_type]}

#{body}
    EMAIL

    if attachments?
      message += attachments_string
      message += <<-EMAIL
--#{marker}--
      EMAIL
    end

    message
  end

  protected

  def attachments_string
    @attachments.map do |a|
      filename = a[:filename]
      content  = [a[:contents]].pack("m") # Base64 encoding

      <<-ATTACHMENT
--#{marker}
Content-Type: multipart/mixed; name="#{filename}"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{filename}"

#{content}
      ATTACHMENT
    end.join("")
  end

  def marker
    @marker ||= Digest::SHA1.hexdigest(self.class.to_s + Time.now.to_i.to_s)
  end

end
