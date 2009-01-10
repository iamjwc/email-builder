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
end

