
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

  def extract_keyboard(args)
    args.partition do |arg|
      arg == '!!'
    end
  end


  def parse_query(args)
    out = {}
    rest = args

    order,  rest = extract_order(rest)
    kbd,    rest = extract_keyboard(rest)
    paging, rest = extract_paging(rest)

    out[:order]    = order if order
    out[:paging]   = paging
    out[:keyboard] = kbd
    out[:keywords] = rest

    out
  end
end
