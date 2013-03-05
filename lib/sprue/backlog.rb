class Sprue::Backlog
  # == Extensions ===========================================================

  # == Constants ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize
    @queues = Hash.new { |h, k| h[k] = Sprue::SortedArray.new }
  end

  def empty?
    @queues.empty? or !@queues.find(&:any?)
  end

  def job_pop!(*tags)
    tags.flatten.each do |tag|
      next unless (@queues.key?(tag))

      if (job = @queues[tag].shift)
        if (@queues[tag].empty?)
          @queues.delete(tag)
        end

        job.tags.each do |tagged|
          next if (tagged == tag)

          set = @queues[tagged]

          set.delete(job)

          if (set.empty?)
            @queues.delete(tagged)
          end
        end

        return job
      end
    end

    return
  end

  def job_peek(*tags)
    tags.flatten.each do |tag|
      next unless (@queues.key?(tag))

      if (job = @queues[tag][0])
        return job
      end
    end
  end

  def job_push!(job)
    job.tags.each do |tag|
      @queues[tag] << job
    end
  end

  def job_remove!(job)
    job.tags.each do |tag|
      next unless (@queues.key?(tag))

      @queues[tag].delete(job)
    end
  end

  def job_tagged(tag)
    return [ ] unless (@queues.key?(tag))

    @queues[tag]
  end
end
