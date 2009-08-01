require 'spec/helper'

describe EmailBuilder do
  before do
    @defaults = {
      :to      => "iamjwc@gmail.com",
      :from    => "iamNOTjwc@gmail.com",
      :subject => "SubjectSubjectSubject",
      :body    => "This is body text"
    }

    @default_email = EmailBuilder.new(@defaults)

    @attachments   = [
      EmailBuilder::Attachment.new("file1.txt", "contents of the file"),
      EmailBuilder::Attachment.new("file2.txt", "these are different file contents")
    ]
  end

  describe "without attachments" do
    it "should send emails with a default content-type of html" do
      @default_email.to_s.should =~ /Content-Type: text\/html/
    end

    it "should have the body as the last line" do
      @default_email.to_s.split("\n").last.should =~ /#{@defaults[:body]}/
    end

    it "should have blank line before body" do
      @default_email.to_s.split("\n")[-2].should == ""
    end
  end

  describe "with attachments" do
    before do
      @attachments.each do |a|
        @default_email.attach(a)
      end
    end

    it "should have number of attachments + 3 occurances of the marker" do
      regexp = /(#{@default_email.attachments.marker})/

      matches = @default_email.to_s.split(regexp).select {|s| s =~ regexp }

      matches.size.should == @default_email.attachments.size + 3
    end

    it "should have 1 content type declarations (1 html, 1 multipart, 2 text)" do
      matches = @default_email.to_s.scan(/Content-Type: ([a-z-]*\/[a-z-]*)/).flatten
      matches.should == [
        "multipart/mixed",
        "text/html",
        "text/plain",
        "text/plain"
      ]
    end
  end
end

