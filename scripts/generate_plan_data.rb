#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
YAML_PATH = File.join(ROOT, "run-plan.yaml")
OUTPUT_PATH = File.join(ROOT, "run-data.generated.js")

PHASE_BY_WEEK = {
  "R1" => "ret", "R2" => "ret",
  "1" => "p1", "2" => "p1", "3" => "p1",
  "4" => "p2", "5" => "p2", "6" => "p2", "7" => "p2", "8" => "p2", "9" => "p2",
  "10" => "p3", "11" => "p3",
  "12" => "taper", "13" => "taper",
  "14" => "hm1", "15" => "hm1", "16" => "hm1",
  "17" => "hm2", "18" => "hm2", "19" => "hm2", "20" => "hm2",
  "21" => "hm3", "22" => "hm3", "23" => "hm3", "24" => "hm3",
  "25" => "hm4", "26" => "hm4", "27" => "hm4",
  "28" => "hmr"
}.freeze

TYPE_SUFFIX = {
  "intv" => "",
  "thr" => "thr",
  "rec" => "rec",
  "easy" => "",
  "lng" => "long",
  "rest" => "",
  "race" => ""
}.freeze

def plain_html(value)
  value.to_s
       .gsub(/<br\s*\/?>/i, "\n")
       .gsub(/<[^>]+>/, "")
       .gsub("&times;", "x")
       .gsub("&ndash;", "-")
       .gsub("&mdash;", "-")
       .gsub("&asymp;", "~")
       .gsub("&deg;", "deg")
       .gsub("&amp;", "&")
       .gsub(/\s+/, " ")
       .strip
end

def week_id(week_html)
  week_html.to_s[/R?\d+/]
end

def km_value(total_km_html)
  numbers = plain_html(total_km_html).scan(/\d+(?:\.\d+)?/).map(&:to_f)
  return 0 if numbers.empty?

  value = numbers.length >= 2 ? ((numbers[0] + numbers[1]) / 2.0) : numbers[0]
  value == value.to_i ? value.to_i : value.round(1)
end

def short_label(day)
  type = day.fetch("type")
  text = plain_html(day.fetch("content_html"))
  first_line = plain_html(day.fetch("content_html").to_s.split(/<br\s*\/?>/i).first)

  return "Rest" if type == "rest"
  return race_label(text) if type == "race"

  session = text[/Session:\s*([^@,(]+)/, 1]&.strip
  distance = first_line[/\b\d+(?:\.\d+)?\s*km\b/i]&.gsub(/\s+/, "")

  if type == "rec"
    distance = text[/\b\d+(?:\.\d+)?\s*km\b/i]&.gsub(/\s+/, "")
    return distance ? "#{distance} rec" : "X-train" if first_line.match?(/cross-train|bike|pool/i)
    return "#{distance} rec" if distance
  end

  base =
    if %w[intv thr].include?(type) && session
      session.gsub(/\s+continuous\b/i, "")
    elsif distance
      distance
    elsif first_line.match?(/cross-train|bike|pool/i)
      "X-train"
    else
      first_line.split(/[.-]/).first.to_s.strip
    end

  base = base.gsub("x", "×")
  base += " +hills" if type == "easy" && text.match?(/hill sprint/i)
  base += " +strides" if type == "easy" && !base.include?("+") && text.match?(/strides/i)
  base += " prog" if type == "lng" && text.match?(/progression|last \d+km|moderate|build/i)
  suffix = TYPE_SUFFIX.fetch(type, "")
  [base, suffix].reject(&:empty?).join(" ")
end

def race_label(text)
  return "LOMBOK 10K" if text.match?(/Lombok 10K/i)
  return "BALI HM" if text.match?(/Bali Half Marathon/i)
  return "10K RACE" if text.match?(/10K/i)
  return "HM RACE" if text.match?(/Half Marathon/i)

  "Race"
end

data = YAML.load_file(YAML_PATH)

weeks = data.fetch("blocks").flat_map do |block|
  block.fetch("phases").flat_map do |phase|
    phase.fetch("weeks").map do |week|
      id = week_id(week.fetch("week_html"))
      days = week.fetch("days").map do |day|
        {
          "t" => day.fetch("type"),
          "s" => short_label(day),
          "l" => day.fetch("content_html")
        }
      end

      {
        "id" => id,
        "dates" => plain_html(week.fetch("dates_html")).gsub("-", "–"),
        "km" => km_value(week.fetch("total_km_html")),
        "phase" => PHASE_BY_WEEK.fetch(id),
        "cutback" => week.fetch("week_html").to_s.include?("↓"),
        "race" => days.any? { |day| day["t"] == "race" },
        "days" => days
      }.reject { |key, value| %w[cutback race].include?(key) && value == false }
    end
  end
end

File.write(OUTPUT_PATH, <<~JS)
  // Generated from run-plan.yaml by scripts/generate_plan_data.rb.
  // Do not edit by hand.
  window.RUN_PLAN_WEEKS = #{JSON.pretty_generate(weeks)};
JS
