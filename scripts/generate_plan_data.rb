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
  "17" => "oct-hm-peak", "18" => "oct-hm-peak", "19" => "oct-hm-peak",
  "20" => "oct-hm-peak", "21" => "oct-hm-peak", "22" => "oct-hm-peak",
  "23" => "oct-hm-peak", "24" => "oct-hm-peak", "25" => "oct-hm-peak"
}.freeze

TYPE_SUFFIX = {
  "intv" => "",
  "thr" => "thr",
  "rec" => "rec",
  "easy" => "",
  "lng" => "long",
  "qlng" => "long+",
  "med" => "med",
  "steady" => "med",
  "hm" => "HM",
  "shake" => "rec",
  "rest" => "",
  "race" => ""
}.freeze

QUALITY_LONG_TAGS = %w[hm-specific steady threshold].freeze

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

  return plain_html(day["label_html"]) if day["label_html"]
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
  return "MAY 10K" if text.match?(/May 24 10K/i)
  return "AUG HM" if text.match?(/Aug 23/i)
  return "OCT HM" if text.match?(/Oct 25.*(?:HM|Half Marathon)/i)
  return "HM RACE" if text.match?(/Half Marathon/i)
  return "10K RACE" if text.match?(/10K/i)

  "Race"
end

def serialize_day(day, race_notes = nil)
  type = day.fetch("type")
  display_type = if type == "lng" && (Array(day["tags"]) & QUALITY_LONG_TAGS).any?
                   "qlng"
                 else
                   type
                 end

  {
    "t" => display_type,
    "s" => short_label(day),
    "l" => day.fetch("content_html"),
    "tags" => day["tags"],
    "pace" => day["pace_html"],
    "priority" => day["priority"],
    "raceNotes" => type == "race" ? race_notes : nil
  }.compact
end

data = YAML.load_file(YAML_PATH)
plan_block = data.fetch("blocks").first || {}

weeks = data.fetch("blocks").flat_map do |block|
  block.fetch("phases").flat_map do |phase|
    phase.fetch("weeks").map do |week|
      id = week_id(week.fetch("week_html"))
      days = week.fetch("days").map do |day|
        serialize_day(day, week["race_notes_html"])
      end

      alternatives = Array(week["alternatives"]).map do |alternative|
        alternative_days = alternative.fetch("days").map do |day|
          serialize_day(day, alternative["race_notes_html"] || week["race_notes_html"])
        end

        {
          "label" => plain_html(alternative["label_html"] || "Alternative"),
          "km" => km_value(alternative.fetch("total_km_html")),
          "kmLabel" => plain_html(alternative.fetch("total_km_html")).gsub("-", "–"),
          "template" => alternative["template"],
          "notes" => alternative["notes_html"],
          "race" => alternative_days.any? { |day| day["t"] == "race" },
          "days" => alternative_days
        }.reject { |key, value| value.nil? || (key == "race" && value == false) }
      end

      {
        "id" => id,
        "dates" => plain_html(week.fetch("dates_html")).gsub("-", "–"),
        "km" => km_value(week.fetch("total_km_html")),
        "kmLabel" => plain_html(week.fetch("total_km_html")).gsub("-", "–"),
        "phase" => PHASE_BY_WEEK.fetch(id),
        "template" => week["template"],
        "notes" => week["notes_html"],
        "alternatives" => alternatives,
        "cutback" => week.fetch("week_html").to_s.include?("↓"),
        "race" => days.any? { |day| day["t"] == "race" },
        "days" => days
      }.reject { |key, value| value.nil? || (key == "alternatives" && value.empty?) || (%w[cutback race].include?(key) && value == false) }
    end
  end
end

File.write(OUTPUT_PATH, <<~JS)
  // Generated from run-plan.yaml by scripts/generate_plan_data.rb.
  // Do not edit by hand.
  window.RUN_PLAN_META = #{JSON.pretty_generate({
    "planNote" => plan_block["plan_note_html"]
  }.compact)};
  window.RUN_PLAN_WEEKS = #{JSON.pretty_generate(weeks)};
JS
