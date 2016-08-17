class StatusJob
  include Resque::Plugins::Status

  def wait_for_completion(identifier, job_ids)
    return 0 unless job_ids.any?

    total_jobs = job_ids.length
    running_jobs = total_jobs
    
    completed = 0
    failures = 0
    job_statuses = {}

    while running_jobs > 0
      job_statuses = retrieve_status(job_ids)

      job_statuses.each do |job_id, status|
        if %w(completed failed killed).include?(status.status)
          completed += 1
          job_ids.delete(job_id)
          running_jobs -= 1
          
          failures += status['failed'] if status['failed'].present?
        end

        update(identifier, total_jobs, completed)
       
      end  
    end

    failures
  end

  def retrieve_status(job_ids)
    statuses = {}

    job_ids.each { |job| statuses[job] = Resque::Plugins::Status::Hash.get(job) }
    
    statuses  
  end

end
