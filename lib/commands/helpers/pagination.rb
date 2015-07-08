
module Pagination
  DEFAULT_PAGE  = 1
  DEFAULT_COUNT = Config.fondbot.pagination.default_count || 10

  def paginate_query(dataset, paging_args)
    paging_args = [] if paging_args.nil?

    paging = parse_paging(paging_args)

    page  = paging[:page]
    count = paging[:count]

    total = dataset.count

    {
      result: dataset.limit(count, (page - 1) * count),
      page: page,
      count: count,
      total: total,
      total_page: (total / count.to_f).ceil
    }
  end

  def pagination_text(opt)
    p opt
    out = 'page '
    out << opt[:page].to_s
    out << '/'
    out << opt[:total_page].to_s
    out
  end

  def pagination_keyboard(cmd, opt, args)
    _, np = args.partition { |x| x.start_with?('!') }

    cmd_prefix = "/#{cmd} #{np.join(' ')}"
    cmd_suffix = opt[:count] == DEFAULT_COUNT ? '' : "!c#{opt[:count]}"

    btns = []

    if opt[:page] > 2
      btns << "#{cmd_prefix} !p#{(opt[:page]-1).to_s} #{cmd_suffix}"
    elsif opt[:page] == DEFAULT_PAGE + 1
      btns << "#{cmd_prefix} #{cmd_suffix}"
    end

    if opt[:page] < opt[:total_page]
      btns << "#{cmd_prefix} !p#{(opt[:page]+1).to_s} #{cmd_suffix}"
    end

    btns
  end

  private

  def parse_paging(args)
    paging = {}
    args.each do |arg|
      next unless arg.start_with?('!')

      case arg
      when /^\!p/
        paging[:page]  = arg[2..-1].to_i
      when /^\!c/
        paging[:count] = arg[2..-1].to_i
      end
    end

    paging[:page]  ||= DEFAULT_PAGE
    paging[:count] ||= DEFAULT_COUNT

    paging
  end
end
