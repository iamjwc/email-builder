require 'digest/sha1'
require 'time'

class EmailBuilder
  attr_accessor :to, :from, :cc, :bcc, :subject, :body, :body_content_type
  attr_reader   :attachments

  class Attachment
    def initialize(filename, contents)
      @filename = filename
      @contents = contents
    end

    def to_s
      s =  "Content-Type: multipart/mixed; name=\"#{@filename}\"\n"
      s += "Content-Transfer-Encoding:base64\n"
      s += "Content-Disposition: attachment; filename=\"#{@filename}\"\n"
      s += "\n"
      s += "#{[@contents].pack("m")}\n" # Base64 encoding

      s
    end
  end

  class AttachmentStore < Array
    def header
      if empty?
        ""
      else
        s = [
          "Content-Type: multipart/mixed; boundary=#{marker}",
          "--#{marker}",
          "Content-Transfer-Encoding: 8bit"
        ].join("\n") + "\n"
      end
    end

    def to_s
      if empty?
        ""
      else
        s = ""
        self.each do |attachment|
          s += "--#{marker}\n"
          s += attachment.to_s
        end
        s += "--#{marker}--\n"

        s
      end
    end

    def marker
      @marker ||= Digest::SHA1.hexdigest(self.class.to_s + Time.now.to_i.to_s)
    end
  end

  TYPES = {
    :html  => "text/html",
    :plain => "text/plain"
  }

  def initialize(opts)
    @attachments = AttachmentStore.new
    @body_content_type = :html
    @to  = @to.split(",")  if @to.respond_to?  :split
    @cc  = @cc.split(",")  if @cc.respond_to?  :split
    @bcc = @bcc.split(",") if @bcc.respond_to? :split

    opts.each do |k, v|
      self.send("#{k}=", v) if self.respond_to?("#{k}=")
    end
  end

  def recipients
    @to + @cc + @bcc
  end

  def attach(attachment)
    @attachments << attachment
  end

  def to_s
    message = [
      "From: #{from}",
      "To: #{[*to].join(",")}",
      "CC: #{[*cc].join(",")}",
      "BCC: #{[*bcc].join(",")}",
      "Subject: #{subject}",
      "Date: #{Time.now.rfc2822}",
      "MIME-Version: 1.0"
    ].join("\n") + "\n"
    
    message += @attachments.header

    message += [
      "Content-Type: #{TYPES[body_content_type]}",
      "",
      "#{body}"
    ].join("\n") + "\n"

    message += @attachments.to_s

    message
  end
end
