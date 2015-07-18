
module KeywordQuery
  include Sequel

  QUOTES = %w[“” “" "" ‘’ ‘' '' 「」 『』]

  def parse_keywords_sub(kws)
    case
    when Array === kws
      { or: kws.map { |x| parse_keywords_sub(x) } }
    when String === kws && is_quoted?(kws)
      { exact: kws[1..-2] }
    when String === kws
      { partial: kws }
    end
  end

  def is_quoted?(kws)
    QUOTES.each do |qmark|
      ql, qr = qmark.split
      return true if kws.start_with?(ql) and kws.end_with?(qr)
    end
    false
  end

  def parse_keywords(kws)
    {
      and: kws.map { |x|
        parse_keywords_sub(x.split('|'))
      }
    }
  end

  def keyword_query(dataset, field, keywords)
    return dataset if keywords.nil?

    kws = parse_keywords(keywords)
    cond = construct_sequel_condition(field, kws)
    dataset.where(cond)
  end

  def construct_sequel_condition(field, expr)
    key, val = expr.first
    case key
    when :exact
      { field => val }
    when :partial
      Sequel.like(field, "%#{val}%")
    when :and
      subs = val.map { |x|
        construct_sequel_condition(field, x)
      }
      Sequel.&(*subs)
    when :or
      subs = val.map { |x|
        construct_sequel_condition(field, x)
      }
      Sequel.|(*subs)
    end
  end
end
