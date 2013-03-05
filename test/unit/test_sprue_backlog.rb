require_relative '../helper'

class TestSprueBacklog < Test::Unit::TestCase
  def test_defaults
    backlog = Sprue::Backlog.new

    assert_equal true, backlog.empty?
  end

  def test_push
    job_specs = {
      %w[ 1 ] => %w[ c f b ],
      %w[ 2 ] => %w[ d e a ],
      %w[ 3 4 ] => %w[ g i j h ],
      %w[ 1 4 5 6 ] => %w[ l k q ]
    }

    jobs = [ ]

    job_specs.each do |tags, idents|
      idents.each do |ident|
        jobs << Sprue::Job.new(
          :ident => ident,
          :priority => ident.ord,
          :tags => tags
        )
      end
    end

    assert_equal job_specs.inject(0) { |s,(t,i)| s + i.length }, jobs.length

    backlog = Sprue::Backlog.new

    jobs.each do |job|
      backlog.job_push!(job)
    end

    assert_equal false, backlog.empty?

    assert_equal %w[ b c f k l q ], backlog.job_tagged('1').collect(&:ident)

    assert_equal 'b', backlog.job_peek('1').ident

    job = backlog.job_pop!('1')

    assert_equal 'b', job.ident
    assert_equal %w[ c f k l q ], backlog.job_tagged('1').collect(&:ident)

    popped = [ ]

    3.times do
      popped << backlog.job_pop!('1')
    end

    assert_equal %w[ c f k ], popped.collect(&:ident)

    job = backlog.job_pop!('1')

    assert_equal %w[ q ], backlog.job_tagged('1').collect(&:ident)
    assert_equal %w[ q ], backlog.job_tagged('6').collect(&:ident)

    job = backlog.job_pop!('1')

    assert_equal 'q', job.ident

    assert_equal %w[ ], backlog.job_tagged('1').collect(&:ident)
  end
end
