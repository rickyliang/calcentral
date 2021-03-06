require 'spec_helper'
require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_academics_page'
require_relative '../util/web_driver_utils'

module CalCentralPages

  class MyAcademicsClassPage < MyAcademicsPage

    include PageObject
    include CalCentralPages
    include ClassLogger

    span(:class_breadcrumb, :xpath => '//h1/span[@data-ng-bind="selectedCourse.course_code"]')

    # CLASS INFO
    h1(:class_info_heading, :xpath => '//h2[text()="Class information"]')
    div(:course_title, :xpath => '//h3[text()="Class Title"]/following-sibling::div[@data-ng-bind="selectedCourse.title"]')
    div(:role, :xpath => '//h3[text()="My Role"]/following-sibling::div[@data-ng-bind="selectedCourse.role"]')
    elements(:student_section_label, :td, :xpath => '//h3[text()="My Enrollment"]/following-sibling::div[@data-ng-if="selectedCourse.sections.length && !isInstructorOrGsi"]//td[@data-ng-bind="sec.section_label"]')
    elements(:student_section_ccn, :td, :xpath => '//h3[text()="My Enrollment"]/following-sibling::div[@data-ng-if="selectedCourse.sections.length && !isInstructorOrGsi"]//td[@data-ng-bind="sec.ccn"]')
    elements(:section_units, :td, :xpath => '//h3[text()="Class Info"]/following-sibling::div[@data-ng-hide="isInstructorOrGsi"]//td[@data-ng-if="section.units"]')
    elements(:section_grade_option, :td, :xpath => '//h4[text()="Course Offering"]/following-sibling::div[@data-ng-hide="isInstructorOrGsi"]//td[@data-ng-bind="section.gradeOption"]')
    elements(:section_schedule_label, :div, :xpath => '//div[@data-ng-repeat="section in selectedCourse.sections"]/div[@data-ng-bind="section.section_label"]')
    elements(:section_schedule, :div, :xpath => '//h4[text()="Section Schedules"]/following-sibling::div[@data-ng-repeat="section in selectedCourse.sections"]//div[@data-ng-repeat="schedule in section.schedules"]')
    elements(:section_instructors_heading, :h3, :xpath => '//h3[@data-ng-bind="section.section_label"]')

    # WEBCAST
    h2(:webcast_heading, :xpath => '//h2[text()="Webcasts"]')
    div(:webcast_spinner_gone, :xpath => '//div[@data-ng-controller="WebcastController"]/div[@data-cc-spinner-directive=""]')
    button(:video_tab, :xpath => '//button[text()="Video"]')
    div(:no_video_msg, :xpath => '//div[contains(.,"No video content available.")]')
    select(:video_select, :xpath => '//select[@data-ng-model="selectedVideo"]')
    button(:video_thumbnail, :xpath => '//button[@id="cc-youtube-image-placeholder"]/img')
    element(:video_iframe, 'iframe')
    link(:itunes_video_link, :xpath => '//li[@class="cc-widget-webcast-itunes-link"]/a')
    button(:audio_tab, :xpath => '//button[text()="Audio"]')
    div(:no_audio_msg, :xpath => '//div[contains(.,"No audio content available.")]')
    select(:audio_select, :xpath => '//select[@data-ng-model="selectedAudio"]')
    audio(:audio, :xpath => '//audio')
    audio(:audio_source, :xpath => '//audio/source')
    link(:audio_download_link, :xpath => '//li[@data-ng-if="selectedAudio.downloadUrl"]/a')
    link(:itunes_audio_link, :xpath => '//li[@data-ng-if="itunes.audio"]/a')
    div(:no_webcast_msg, :xpath => '//div[contains(.,"There are no webcasts available.")]')

    def all_student_section_labels
      labels = []
      student_section_label_elements.each { |label| labels.push(label.text) }
      labels
    end

    def all_student_section_ccns
      ccns = []
      student_section_ccn_elements.each { |ccn| ccns.push(ccn.text) }
      ccns
    end

    def all_section_units
      units = []
      section_units_elements.each { |unit| units.push(unit.text) }
      units
    end

    def all_section_grade_options
      options = []
      section_grade_option_elements.each { |option| options.push(option.text) }
      options
    end

    def all_section_schedule_labels
      labels = []
      section_schedule_label_elements.each { |label| labels.push(label.text) }
      labels
    end

    def all_section_schedules
      schedules = []
      section_schedule_elements.each { |schedule| schedules.push(schedule.text) }
      schedules
    end

    def all_section_instructors(driver, section_label)
      instructors = []
      instructor_elements = driver.find_elements(:xpath => "//h3[text()='#{section_label}']/following-sibling::ul/li[@data-ng-repeat='instructor in section.instructors']/a")
      instructor_elements.each { |instructor| instructors.push((instructor.text).gsub("\n- opens in new window", '')) }
      instructors
    end

    def all_course_instructors(driver, sections)
      instructors = []
      sections.each do |section|
        instructors.push(all_section_instructors(driver, section))
      end
      instructors
    end

    def wait_for_webcasts
      webcast_heading_element.when_present(WebDriverUtils.page_load_timeout)
      webcast_spinner_gone_element.when_present(WebDriverUtils.page_load_timeout)
    end

    def you_tube_video_auto_plays?(driver)
      video_thumbnail_element.click
      wait_until(timeout=WebDriverUtils.page_event_timeout) { driver.find_element(:xpath, '//iframe') }
      driver.switch_to.frame driver.find_element(:xpath, '//iframe')
      wait_until(timeout=WebDriverUtils.page_event_timeout) { driver.find_element(:xpath, '//div[@class="html5-player-chrome"]') }
      auto_play = driver.find_element(:xpath, '//div[@class="ytp-button ytp-button-pause"]').displayed?
      driver.switch_to.default_content
      auto_play
    end
  end
end
