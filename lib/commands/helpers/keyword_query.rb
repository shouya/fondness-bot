
module KeywordQuery
  include Sequel

  def parse_keywords_sub(kws)
    case
    when Array === kws
      { or: kws.map { |x| parse_keywords_sub(x) } }
    when String === kws &&
         kws.start_with?('"') &&
         kws.end_with?('"')
      { exact: kws }
    when String === kws
      { partial: kws }
    end
  end

  def parse_keywords(kws)
    {
      and: kws.map { |x|
        parse_keywords_sub(x)
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
