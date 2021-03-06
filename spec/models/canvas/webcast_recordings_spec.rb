describe Canvas::WebcastRecordings do

  describe '#get_feed' do
    let(:canvas_course_id) { rand(99999) }
    before do
      allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(
        double(body: canvas_course_sections_list.to_json, status: 200)
      )
    end

    subject { Canvas::WebcastRecordings.new({course_id: canvas_course_id, fake: true}) }

    context 'when the Canvas course site maps to campus class sections' do
      let(:canvas_course_sections_list) do
        [
          {'id' => rand(99999).to_s, 'name' => 'a', 'course_id' => canvas_course_id, 'sis_section_id' => nil},
          {'id' => rand(99999).to_s, 'name' => 'b', 'course_id' => canvas_course_id, 'sis_section_id' => 'SEC:2009-B-49982'},
          {'id' => rand(99999).to_s, 'name' => 'c', 'course_id' => canvas_course_id, 'sis_section_id' => 'SEC:2009-B-81853'}
        ]
      end

      it 'contains two sets of recordings' do
        feed = subject.get_feed
        expect(feed[:system_status]['is_sign_up_active']).to be true
        expect(feed[:rooms]).to have(26).items
        expect(feed[:media]).to have(2).items

        law_27171 = feed[:media]['2009-B-49982']
        expect(law_27171[:audio]).to have(13).items
        expect(law_27171[:audio][12][:title]).to match('Lecture 1')
        expect(law_27171[:itunes][:audio]).to end_with('354822513')
        expect(law_27171[:itunes][:video]).to end_with('354822509')

        sociol_150A = feed[:media]['2009-B-81853']
        expect(law_27171[:audio]).to have_at_least(10).items
        expect(law_27171[:audio][12][:title]).to_not be_nil
        expect(law_27171[:itunes][:audio]).to_not be_nil
        expect(law_27171[:itunes][:video]).to_not be_nil
      end
    end

    context 'when the Canvas site does not map to any campus class sections' do
      let(:canvas_course_sections_list) do
        [
          {'id' => rand(99999).to_s, 'name' => 'a', 'course_id' => canvas_course_id, 'sis_section_id' => nil},
          {'id' => rand(99999).to_s, 'name' => 'b', 'course_id' => canvas_course_id, 'sis_section_id' => 'fuggidaboudit'}
        ]
      end
      it 'is empty' do
        feed = subject.get_feed
        expect(feed[:system_status]['is_sign_up_active']).to be true
        expect(feed[:rooms]).to have(26).items
        expect(feed[:media]).to be_empty
      end
    end
  end

end
