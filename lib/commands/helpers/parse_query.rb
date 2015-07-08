
module QueryParser
  def extract_order(args)
    args.partition do |arg|
      arg.start_with?('<')
    end
  end

  def extract_paging(args)
    args.partition do |arg|
      arg.start_with?('!')
    end
  end


  def parse_query(args)
    out = {}
    rest = args

    order,  rest = extract_order(rest)
    paging, rest = extract_paging(rest)

    out[:order]    = order if order
    out[:paging]   = paging
    out[:keywords] = rest

    out
  end
end
