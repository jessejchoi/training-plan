#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

class RunPlanSync
  ROOT = File.expand_path("..", __dir__)
  INDEX_PATH = File.join(ROOT, "index.html")
  YAML_PATH = File.join(ROOT, "run-plan.yaml")

  TABLE_HEADERS = [
    { style: "min-width:100px", html: "Wk &amp; Dates" },
    { style: "min-width:46px", html: "~km" },
    { style: "min-width:44px", html: "Mon" },
    { style: "min-width:188px", html: "Tue &mdash; Intervals" },
    { style: "min-width:115px", html: "Wed &mdash; Recovery" },
    { style: "min-width:188px", html: "Thu &mdash; Threshold" },
    { style: "min-width:110px", html: "Fri &mdash; Recovery" },
    { style: "min-width:118px", html: "Sat &mdash; Easy" },
    { style: "min-width:172px", html: "Sun &mdash; Long Run" }
  ].freeze

  def initialize(action)
    @action = action
  end

  def run
    case @action
    when "bootstrap"
      bootstrap_yaml
      render_into_index
    when "render"
      render_into_index
    else
      abort "Usage: ruby scripts/run_plan_sync.rb [bootstrap|render]"
    end
  end

  private

  def bootstrap_yaml
    html = File.read(INDEX_PATH)
    run_content = html[/<div id="runs-content">\s*(.*?)\s*<\/div><!-- \/runs-content -->/m, 1]
    raise "Could not locate runs-content in index.html" unless run_content

    ten_k_html, hm_html = run_content.split(/<!-- HM SECTION -->/, 2)
    raise "Could not split 10K and HM run sections" unless ten_k_html && hm_html

    data = {
      "version" => 1,
      "blocks" => [
        parse_primary_block(ten_k_html),
        parse_hm_block(hm_html)
      ]
    }

    File.write(YAML_PATH, YAML.dump(data))
  end

  def parse_primary_block(html)
    {
      "kind" => "run-table-section",
      "section_id" => html[/<div class="section"[^>]*id="([^"]+)"/, 1],
      "section_style" => html[/<div class="section" style="([^"]+)"/, 1],
      "legend" => html.scan(/<span class="li"><span class="ld ([^"]+)"><\/span>(.*?)<\/span>/m).map { |klass, label| { "class" => klass, "label_html" => label.strip } },
      "phases" => parse_table_phases(html),
      "callout_html" => html[%r{<div class="callout" style="margin-top:16px;">(.*?)</div>}m, 1]&.strip,
      "plan_note_html" => html[%r{<p class="plan-note">(.*?)</p>}m, 1]&.strip
    }
  end

  def parse_hm_block(html)
    {
      "kind" => "sectioned-run-table",
      "section_id" => html[/<div class="section"[^>]*id="([^"]+)"/, 1],
      "section_number_html" => html[%r{<span class="section-number">(.*?)</span>}m, 1]&.strip,
      "title_html" => html[%r{<h2>(.*?)</h2>}m, 1]&.strip,
      "callout_html" => html[%r{<div class="callout">(.*?)</div>}m, 1]&.strip,
      "phases" => parse_table_phases(html),
      "plan_note_html" => html[%r{<p class="plan-note">(.*?)</p>}m, 1]&.strip
    }
  end

  def parse_table_phases(html)
    tbody = html[%r{<tbody>(.*?)</tbody>}m, 1]
    raise "Could not find tbody while bootstrapping run plan" unless tbody

    phases = []
    current_phase = nil

    tbody.scan(%r{<tr class="ph"(?: id="([^"]+)")?><td colspan="9">(.*?)</td></tr>|<tr>\s*<td><div class="wk">(.*?)</div><div class="dt">(.*?)</div></td><td class="tkm">(.*?)</td>(.*?)</tr>}m) do |phase_id, phase_title, week, dates, total_km, days_html|
      if phase_title
        current_phase = {
          "id" => phase_id,
          "title_html" => phase_title.strip,
          "weeks" => []
        }
        phases << current_phase
        next
      end

      raise "Encountered week row before phase heading" unless current_phase

      days = days_html.scan(%r{<td><span class="s ([^"]+)">(.*?)</span></td>}m).map do |type, content|
        { "type" => type, "content_html" => content.strip }
      end

      current_phase["weeks"] << {
        "week_html" => week.strip,
        "dates_html" => dates.strip,
        "total_km_html" => total_km.strip,
        "days" => days
      }
    end

    phases
  end

  def render_into_index
    data = YAML.load_file(YAML_PATH)
    rendered = render_blocks(data.fetch("blocks"))

    html = File.read(INDEX_PATH)
    pattern = %r{<div id="runs-content">.*?</div><!-- /runs-content -->}m
    raise "Could not locate runs-content in index.html" unless html.match?(pattern)

    updated = html.sub(pattern, <<~HTML.chomp)
      <div id="runs-content">
      #{rendered}
      </div><!-- /runs-content -->
    HTML

    File.write(INDEX_PATH, updated)
  end

  def render_blocks(blocks)
    blocks.map do |block|
      case block.fetch("kind")
      when "run-table-section"
        render_run_table_section(block)
      when "sectioned-run-table"
        render_sectioned_run_table(block)
      else
        raise "Unknown run plan block kind: #{block['kind']}"
      end
    end.join("\n\n<!-- HM SECTION -->\n")
  end

  def render_run_table_section(block)
    style_attr = block["section_style"] ? %( style="#{block['section_style']}") : ""
    <<~HTML.chomp
      <div class="section"#{style_attr} id="#{block.fetch('section_id')}">
      #{render_legend(block.fetch("legend"))}
      #{render_table(block.fetch("phases"))}
      <div class="callout" style="margin-top:16px;">#{block.fetch("callout_html")}</div>
      <p class="plan-note">#{block.fetch("plan_note_html")}</p>
      </div>
    HTML
  end

  def render_sectioned_run_table(block)
    <<~HTML.chomp
      <div class="section" id="#{block.fetch('section_id')}">
      <div class="section-header"><span class="section-number">#{block.fetch('section_number_html')}</span><h2>#{block.fetch('title_html')}</h2></div>
      <div class="callout">#{block.fetch("callout_html")}</div>
      #{render_table(block.fetch("phases"))}
      <p class="plan-note">#{block.fetch("plan_note_html")}</p>
      </div>
    HTML
  end

  def render_legend(items)
    labels = items.map do |item|
      %(<span class="li"><span class="ld #{item.fetch('class')}"></span>#{item.fetch('label_html')}</span>)
    end.join("\n  ")

    <<~HTML.chomp
      <div class="legend">
        #{labels}
      </div>
    HTML
  end

  def render_table(phases)
    rows = phases.map { |phase| render_phase(phase) }.join("\n")

    <<~HTML.chomp
      <div class="wrap">
      <table>
      <thead><tr>
        #{TABLE_HEADERS.map { |header| %(<th style="#{header[:style]}">#{header[:html]}</th>) }.join}
      </tr></thead>
      <tbody>
      #{rows}
      </tbody></table>
      </div>
    HTML
  end

  def render_phase(phase)
    phase_id = phase["id"] ? %( id="#{phase['id']}") : ""
    weeks = phase.fetch("weeks").map { |week| render_week(week) }.join("\n")

    <<~HTML.chomp
      <tr class="ph"#{phase_id}><td colspan="9">#{phase.fetch('title_html')}</td></tr>
      #{weeks}
    HTML
  end

  def render_week(week)
    day_cells = week.fetch("days").map do |day|
      %(<td><span class="s #{day.fetch('type')}">#{day.fetch('content_html')}</span></td>)
    end.join("\n")

    <<~HTML.chomp
      <tr>
      <td><div class="wk">#{week.fetch('week_html')}</div><div class="dt">#{week.fetch('dates_html')}</div></td><td class="tkm">#{week.fetch('total_km_html')}</td>
      #{day_cells}
      </tr>
    HTML
  end
end

RunPlanSync.new(ARGV[0]).run
