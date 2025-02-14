module SimulationsHelper
  def badge_class(status)
    case status
    when "draft" then "bg-light text-dark"
    when "open" then "bg-info text-dark"
    when "under_analysis" then "bg-warning"
    when "approved" then "bg-success"
    when "rejected" then "bg-danger"
    else "bg-dark"
    end
  end
end
