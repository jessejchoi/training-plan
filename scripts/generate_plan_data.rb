#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)
YAML_PATH = File.join(ROOT, "run-plan.yaml")
OUTPUT_PATH = File.join(ROOT, "run-data.generated.js")

PHASE_BY_WEEK = {
  "1" => "hm-build", "2" => "hm-build", "3" => "hm-build", "4" => "hm-build",
  "5" => "hm-build", "6" => "hm-build", "7" => "hm-build", "8" => "hm-build",
  "9" => "hm-build", "10" => "hm-build", "11" => "hm-build", "12" => "hm-build",
  "13" => "hm-peak", "14" => "hm-peak", "15" => "hm-peak", "16" => "hm-peak",
  "17" => "tenk-sharpen", "18" => "tenk-sharpen", "19" => "tenk-sharpen",
  "20" => "tenk-sharpen", "21" => "tenk-sharpen", "22" => "tenk-sharpen",
  "23" => "tenk-sharpen", "24" => "tenk-sharpen", "25" => "tenk-sharpen"
}.freeze

TYPE_SUFFIX = {
  "intv" => "",
  "thr" => "thr",
  "rec" => "rec",
  "easy" => "",
  "lng" => "long",
  "med" => "med",
  "steady" => "steady",
  "hm" => "HM",
  "shake" => "shake",
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

  unless first_line.match?(/\A(?:WU|Session|CD):/i)
    return first_line.split(/\s+@\s+/).first.gsub("&ndash;", "-")
  end

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
  return "JULY 10K" if text.match?(/July 12 10K/i)
  return "OCT 10K" if text.match?(/Oct 25 10K/i)
  return "HM RACE" if text.match?(/Aug 23|Half Marathon/i)
  return "10K RACE" if text.match?(/10K/i)
  return "HM RACE" if text.match?(/Half Marathon/i)

  "Race"
end

data = YAML.load_file(YAML_PATH)
plan_block = data.fetch("blocks").first || {}

weeks = data.fetch("blocks").flat_map do |block|
  block.fetch("phases").flat_map do |phase|
    phase.fetch("weeks").map do |week|
      id = week_id(week.fetch("week_html"))
      days = week.fetch("days").map do |day|
        {
          "t" => day.fetch("type"),
          "s" => short_label(day),
          "l" => day.fetch("content_html"),
          "tags" => day["tags"],
          "pace" => day["pace_html"],
          "priority" => day["priority"]
        }.compact
      end

      {
        "id" => id,
        "dates" => plain_html(week.fetch("dates_html")).gsub("-", "–"),
        "km" => km_value(week.fetch("total_km_html")),
        "phase" => PHASE_BY_WEEK.fetch(id),
        "template" => week["template"],
        "notes" => week["notes_html"],
        "raceNotes" => week["race_notes_html"],
        "cutback" => week.fetch("week_html").to_s.include?("↓"),
        "race" => days.any? { |day| day["t"] == "race" },
        "days" => days
      }.reject { |key, value| value.nil? || (%w[cutback race].include?(key) && value == false) }
    end
  end
end

File.write(OUTPUT_PATH, <<~JS)
  // Generated from run-plan.yaml by scripts/generate_plan_data.rb.
  // Do not edit by hand.
  window.RUN_PLAN_META = #{JSON.pretty_generate({
    "paceGuide" => plan_block["pace_guide_html"],
    "planNote" => plan_block["plan_note_html"]
  }.compact)};
  window.RUN_PLAN_WEEKS = #{JSON.pretty_generate(weeks)};
JS
