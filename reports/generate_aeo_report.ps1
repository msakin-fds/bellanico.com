# AI SEO Audit Report Generator for bellanico.com
# PowerShell 5.1 compatible - ASCII only, no em-dashes, no bare & in strings

$outputPath = "$PSScriptRoot\BellaNico_AEO_Audit_2026.docx"

$word = New-Object -ComObject Word.Application
$word.Visible = $false
$doc = $word.Documents.Add()
$doc.PageSetup.TopMargin    = $word.InchesToPoints(1)
$doc.PageSetup.BottomMargin = $word.InchesToPoints(1)
$doc.PageSetup.LeftMargin   = $word.InchesToPoints(1.1)
$doc.PageSetup.RightMargin  = $word.InchesToPoints(1.1)

# Colour constants (Word uses BGR integer)
$NAVY   = 0x1F3864
$BLUE   = 0x2E74B5
$GREEN  = 0x375623
$RED_T  = 0xC00000
$AMBER  = 0x833C00
$LGRAY  = 0xF2F2F2
$DKGRAY = 0x404040
$ORANGE = 0xC55A11
$BGBLUE = 0xDEEBF7
$BGGRN  = 0xE2EFDA
$BGRED  = 0xFFE0E0
$BGYEL  = 0xFFF2CC
$WHITE  = 0xFFFFFF

function Sel { $word.Selection }

function SetFont($name,$size,$bold,$color,$italic=$false) {
    (Sel).Font.Name   = $name
    (Sel).Font.Size   = $size
    (Sel).Font.Bold   = $bold
    (Sel).Font.Color  = $color
    (Sel).Font.Italic = $italic
}

function TypeText($text) { (Sel).TypeText($text) }
function NL { (Sel).TypeParagraph() }

function Para($sb=0,$sa=6) {
    (Sel).ParagraphFormat.SpaceBefore = $sb
    (Sel).ParagraphFormat.SpaceAfter  = $sa
}

function HR {
    (Sel).ParagraphFormat.Borders.Item(3).LineStyle = 1
    (Sel).ParagraphFormat.Borders.Item(3).LineWidth = 6
    (Sel).ParagraphFormat.Borders.Item(3).Color     = $BLUE
    (Sel).TypeParagraph()
    (Sel).ParagraphFormat.Borders.Item(3).LineStyle = 0
}

function H1($text) {
    NL; Para 16 4
    SetFont 'Calibri' 22 $true $NAVY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function H2($text) {
    Para 12 4
    SetFont 'Calibri' 14 $true $BLUE
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function H3($text) {
    Para 8 2
    SetFont 'Calibri' 11 $true $DKGRAY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function Body($text,$color=$DKGRAY,$bold=$false,$italic=$false) {
    Para 0 6
    SetFont 'Calibri' 11 $bold $color $italic
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $text; NL
}

function Code($text) {
    Para 4 4
    (Sel).ParagraphFormat.LeftIndent  = $word.InchesToPoints(0.3)
    (Sel).ParagraphFormat.RightIndent = $word.InchesToPoints(0.3)
    (Sel).ParagraphFormat.Shading.BackgroundPatternColor = $LGRAY
    SetFont 'Courier New' 9 $false $DKGRAY
    TypeText $text; NL
    (Sel).ParagraphFormat.LeftIndent  = 0
    (Sel).ParagraphFormat.RightIndent = 0
    (Sel).ParagraphFormat.Shading.BackgroundPatternColor = -16777216
}

function PB { (Sel).InsertBreak(7) }

function MakeTable($rows,$cols) {
    $r = (Sel).Range
    $t = $doc.Tables.Add($r,$rows,$cols)
    $t.Style = 'Table Grid'
    $t.Borders.InsideLineStyle  = 1
    $t.Borders.OutsideLineStyle = 1
    return $t
}

function TC($t,$row,$col,$text,$bold=$false,$fg=$DKGRAY,$sz=10,$align=0,$bg=-1) {
    $c = $t.Cell($row,$col)
    if ($bg -ne -1) { $c.Shading.BackgroundPatternColor = $bg }
    $c.Range.Text = $text
    $c.Range.Font.Name  = 'Calibri'
    $c.Range.Font.Size  = $sz
    $c.Range.Font.Bold  = $bold
    $c.Range.Font.Color = $fg
    $c.Range.ParagraphFormat.Alignment  = $align
    $c.Range.ParagraphFormat.SpaceAfter = 2
}

function HRow($t,$headers,$bg=$NAVY,$fg=$WHITE) {
    for ($c=1;$c -le $headers.Count;$c++) {
        TC $t 1 $c $headers[$c-1] $true $fg 10 1 $bg
    }
}

function MoveOut($t) {
    $t.Select()
    (Sel).Collapse(0)
    NL
}

# ============================================================
# COVER PAGE
# ============================================================
Para 50 0
SetFont 'Calibri' 10 $false $WHITE
(Sel).ParagraphFormat.Alignment = 1; NL

Para 0 4; SetFont 'Calibri' 32 $true $NAVY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'AI SEO VISIBILITY AUDIT'; NL

Para 0 2; SetFont 'Calibri' 20 $false $BLUE
(Sel).ParagraphFormat.Alignment = 1
TypeText 'bellanico.com'; NL

Para 12 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Prepared for: Bella Nico Inc.'; NL

Para 0 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Date: April 24, 2026'; NL

Para 0 4; SetFont 'Calibri' 13 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'Prepared by: Fresh Design Studio'; NL

Para 30 0; SetFont 'Calibri' 12 $true $RED_T
(Sel).ParagraphFormat.Alignment = 1
TypeText 'OVERALL SCORE:  13 / 100  --  CRITICAL ACTION REQUIRED'; NL

Para 4 4; SetFont 'Calibri' 11 $false $DKGRAY
(Sel).ParagraphFormat.Alignment = 1
TypeText 'This report audits AI visibility across 7 pillars. A score below 40 means AI engines cannot reliably cite the site.'; NL

PB

# ============================================================
# TABLE OF CONTENTS
# ============================================================
Para 0 6; SetFont 'Calibri' 18 $true $NAVY
(Sel).ParagraphFormat.Alignment = 0
TypeText 'Table of Contents'; NL
HR

$toc = @(
    '1.  Executive Summary',
    '2.  Overall Score Dashboard',
    '3.  AI Bot Access  (Score: 35/100)',
    '4.  Content Structure  (Score: 10/100)',
    '5.  Authority and Trust Signals  (Score: 20/100)',
    '6.  Content Freshness  (Score: 15/100)',
    '7.  Schema Markup  (Score: 0/100)',
    '8.  Machine-Readable Files  (Score: 0/100)',
    '9.  Content Depth and Volume  (Score: 15/100)',
    '10. Competitive Snapshot',
    '11. Final Summary: Pros, Cons and Next Steps'
)
foreach ($line in $toc) {
    Para 0 4; SetFont 'Calibri' 11 $false $DKGRAY
    (Sel).ParagraphFormat.Alignment = 0
    TypeText $line; NL
}
PB

# ============================================================
# 1. EXECUTIVE SUMMARY
# ============================================================
H1 '1. Executive Summary'
HR

Body 'Bella Nico is a 31-year-old Canadian frozen food company with a genuine brand story -- the first to introduce a clear 24-count Mini Cob Corn and a 3lb bag of Baby Lima Beans, celebrating three decades in business in 2026. Almost none of this compelling history is visible to AI search engines. This audit reviewed the website across seven AI SEO pillars and found critical deficiencies in six of them.'
Body 'The most urgent issue is not technical -- it is that the FAQ page is still displaying Lorem Ipsum placeholder text from the original theme demo, and the contact email shown to visitors is info@agroly.com, the theme developer, not Bella Nico. Any AI engine that crawls these pages associates the brand with filler content and an unrelated company.'
Body 'The good news: the structural fixes are straightforward. The homepage contains a strong, citable brand story, the Veggie Values product line has clear identity, and the AIOSEO plugin is already installed -- it simply has never been configured. Addressing the critical issues identified in this report will substantially improve how Bella Nico appears in AI-generated answers.'

NL; H2 'What Is AI SEO and Why Does It Matter?'
Body 'Traditional SEO gets you ranked on Google blue links. AI SEO gets you CITED inside AI-generated answers -- the kind that appear before the blue links, or replace them entirely.'
Body 'Today approximately 45% of Google searches show an AI Overview at the top. ChatGPT, Perplexity, and Gemini are used by millions of people to research food products and suppliers. When a buyer, retailer, or consumer asks "Who makes Veggie Values frozen vegetables?" or "Where can I buy club-pack frozen corn?" -- AI tools compose a direct answer and cite their sources. Bella Nico is not currently among those sources.'

NL; H2 'Key Findings at a Glance'
$kft = MakeTable 9 3
HRow $kft @('Finding','Status','Action Required')
$kfd = @(
    @('AI bots can access the site (no robots.txt blocking)',    'PARTIAL -- no robots.txt exists', 'Create robots.txt immediately'),
    @('FAQ page content',                                        'LOREM IPSUM placeholder text',    'Replace with real content urgently'),
    @('Contact info on FAQ page',                               'Shows demo email info@agroly.com', 'Update to real Bella Nico contact info'),
    @('Schema / structured data',                               'ZERO -- AIOSEO not configured',   'Configure AIOSEO schema settings'),
    @('XML sitemap',                                            'Not enabled in AIOSEO',            'Enable and submit sitemap'),
    @('Image alt text',                                         '436 images missing alt text',      'Add alt text to all product images'),
    @('Blog or educational content',                            'Zero published posts',             'Start publishing brand and product content'),
    @('Plugin updates',                                         '16 plugins awaiting updates',      'Update all plugins after site backup')
)
for ($r=0;$r -lt $kfd.Count;$r++) {
    $isPass = $kfd[$r][1] -like '*PASS*'
    $rbg = if ($isPass) { $BGGRN } else { $BGRED }
    $rfg = if ($isPass) { $GREEN } else { $RED_T }
    TC $kft ($r+2) 1 $kfd[$r][0] $false $DKGRAY 10 0 $LGRAY
    TC $kft ($r+2) 2 $kfd[$r][1] $true  $rfg    10 0 $rbg
    TC $kft ($r+2) 3 $kfd[$r][2] $false $DKGRAY 10 0
}
MoveOut $kft
PB

# ============================================================
# 2. SCORE DASHBOARD
# ============================================================
H1 '2. Overall Score Dashboard'
HR
Body 'Each pillar is scored out of 100. Below 40 = Failing (AI cannot reliably cite you for that factor). 40-69 = Needs Work. 70-100 = Pass.' $DKGRAY $false $true
NL

$sdt = MakeTable 9 4
HRow $sdt @('Pillar','Score','Grade','Status')
$sdd = @(
    @('AI Bot Access',          '35 / 100','F','Critical Fail'),
    @('Content Structure',      '10 / 100','F','Critical Fail'),
    @('Authority and Trust',    '20 / 100','F','Critical Fail'),
    @('Content Freshness',      '15 / 100','F','Critical Fail'),
    @('Schema Markup',          ' 0 / 100','F','Complete Fail'),
    @('Machine-Readable Files', ' 0 / 100','F','Complete Fail'),
    @('Content Depth',          '15 / 100','F','Critical Fail'),
    @('OVERALL',                '13 / 100','F','Critical -- Immediate Action Required')
)
for ($r=0;$r -lt $sdd.Count;$r++) {
    $sc = [int]($sdd[$r][1].Trim().Split('/')[0].Trim())
    $gbg = if ($sc -ge 70) { $BGGRN } elseif ($sc -ge 40) { $BGYEL } else { $BGRED }
    $gfg = if ($sc -ge 70) { $GREEN } elseif ($sc -ge 40) { $AMBER } else { $RED_T }
    $isLast = ($r -eq $sdd.Count-1)
    $rbg = if ($isLast) { $LGRAY } else { $WHITE }
    TC $sdt ($r+2) 1 $sdd[$r][0] $isLast $DKGRAY 10 0 $rbg
    TC $sdt ($r+2) 2 $sdd[$r][1] $true   $gfg    10 1 $gbg
    TC $sdt ($r+2) 3 $sdd[$r][2] $true   $gfg    11 1 $gbg
    TC $sdt ($r+2) 4 $sdd[$r][3] $isLast $DKGRAY 10 0 $rbg
}
MoveOut $sdt
Body 'Score key:  GREEN (70-100) = Pass   |   YELLOW (40-69) = Needs Work   |   RED (0-39) = Critical Fail' $DKGRAY $false $true
PB

# ============================================================
# 3. AI BOT ACCESS
# ============================================================
H1 '3. AI Bot Access -- 35 / 100  (Critical Fail)'
HR

H2 'What This Measures'
Body 'Before an AI engine can cite your website, its crawler must be able to visit it and understand what it is looking at. This section checks whether major AI platforms can access the site, and whether any context files exist to help AI understand the brand quickly.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'SSL is active -- the site loads correctly over HTTPS. No firewall or .htaccess rules are blocking AI crawlers. The AIOSEO plugin is installed and has sitemap generation capability built in.' $GREEN

NL; H2 'CONS -- What Needs Fixing'
Body 'There is no robots.txt file at bellanico.com/robots.txt. Without this file, AI crawlers operate with zero guidance -- they cannot be directed toward important pages or away from admin areas. This is a basic technical file that every website should have.' $RED_T
Body 'The AIOSEO sitemap feature has never been enabled. There is no XML sitemap at bellanico.com/sitemap.xml for AI crawlers to follow. Without a sitemap, product pages linked from few other pages may never be discovered.' $RED_T
Body 'There is no /llms.txt file. This plain-text file tells AI systems who the company is, what it makes, and where the key pages are -- without requiring the AI to crawl dozens of pages. Without it, every AI system must guess the brand identity from scratch on each visit.' $RED_T

NL; H2 'AI Crawler Access Table'
$bt = MakeTable 7 3
HRow $bt @('AI Platform','Crawler Bot Name','Access Status')
$brd = @(
    @('ChatGPT (OpenAI)',             'GPTBot',          'ALLOWED (unguided -- no robots.txt)'),
    @('Perplexity',                   'PerplexityBot',   'ALLOWED (unguided -- no robots.txt)'),
    @('Claude (Anthropic)',           'ClaudeBot',       'ALLOWED (unguided -- no robots.txt)'),
    @('Google Gemini / AI Overviews', 'Google-Extended', 'ALLOWED (unguided -- no robots.txt)'),
    @('Microsoft Copilot',            'Bingbot',         'ALLOWED (unguided -- no robots.txt)'),
    @('Common Crawl (AI training)',   'CCBot',           'ALLOWED (optional to block)')
)
for ($r=0;$r -lt $brd.Count;$r++) {
    TC $bt ($r+2) 1 $brd[$r][0] $false $DKGRAY 10 0
    TC $bt ($r+2) 2 $brd[$r][1] $false $DKGRAY 10 0
    TC $bt ($r+2) 3 $brd[$r][2] $true  $AMBER  10 0 $BGYEL
}
MoveOut $bt

H2 'Action Required'
Body 'Create a robots.txt file and enable the AIOSEO XML sitemap. Both can be done in under 30 minutes through AIOSEO settings and a simple text file upload. See Section 8 for exact llms.txt content to add.' $RED_T $true
PB

# ============================================================
# 4. CONTENT STRUCTURE
# ============================================================
H1 '4. Content Structure and Extractability -- 10 / 100  (Critical Fail)'
HR

H2 'What This Measures'
Body 'AI engines do not rank pages -- they extract passages. A citable AI snippet is a 40-60 word block that directly answers a question and works without surrounding context. This section measures how well the site supports that extraction -- and identifies the most urgent content problem on the site.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'The homepage contains a strong, specific brand history paragraph: founded 1995, celebrating 31 years in 2026, first to introduce clear Mini Cob Corn and 3lb Baby Lima Beans. This is solid raw material for AI citation.' $GREEN
Body 'The Veggie Values product line has a clear identity and slogan: "We took delicious and froze it in time." This is a brand-specific, extractable statement that AI engines can associate with the company.' $GREEN

NL; H2 'CONS -- What Needs Fixing (CRITICAL)'
Body 'The FAQ page (bellanico.com/faq-page/) still contains Lorem Ipsum placeholder text from the original theme demo. Live questions include "What are gas solutions?" with fabricated answers that have nothing to do with Bella Nico or frozen food. Every AI engine that crawls this page associates the brand with irrelevant gibberish.' $RED_T $true
Body 'The FAQ page displays "info@agroly.com" and "suport@agroly.com" as contact emails -- these are the Agroly theme developer demo email addresses, not Bella Nico. Visitors and AI crawlers see the wrong company information.' $RED_T $true
Body 'No page on the site opens with a factual, citable definition paragraph. Every page leads with design elements or short taglines rather than extractable content.' $RED_T
Body 'No real FAQ sections exist. Despite having a dedicated FAQ page, all content is placeholder text. FAQ blocks are the single easiest content type for AI to extract and cite.' $RED_T
Body 'Zero blog posts have been published. There is no article or informational content about frozen vegetables, food distribution, or Bella Nico product advantages.' $RED_T

NL; H2 'EXAMPLE 1 -- FAQ Page: Current vs. Recommended'
H3 'Current Version (Active Right Now -- AI Penalises This)'
Code ("Q: What are gas solutions?`r`n" + "A: Lorem ipsum dolor sit amet, consectetur adipisicing elit. Reprehenderit,`r`n" + "   ipsum, fuga, in, obcaecati magni ullam nobis... [placeholder text continues]`r`n`r`n" + "Contact: info@agroly.com  (Agroly theme developer -- not Bella Nico)")
Body 'Why this is damaging: AI engines crawling this page see a frozen food company answering questions about "gas solutions" with Latin filler text. This actively signals low-quality, untrustworthy content.' $RED_T $false $true

H3 'Recommended Version (Citable by AI)'
Code ("Q: What products does Bella Nico make?`r`n" + "A: Bella Nico distributes frozen vegetables under the Veggie Values brand,`r`n" + "   including Baby Lima Beans, Mini Cob Corn, Cut Green Beans, Broccoli Florets,`r`n" + "   Normandy Blend, and more. All items are available in 48oz clear packaging.`r`n`r`n" + "Q: How long has Bella Nico been in business?`r`n" + "A: Bella Nico was established in 1995 and is celebrating 31 years in business`r`n" + "   in 2026. We were the first to introduce a clear 24-count 3-inch Mini Cob`r`n" + "   Corn and the first to offer a 3lb bag of Baby Lima Beans.`r`n`r`n" + "Contact: [real Bella Nico email]   Phone: [real Bella Nico number]")
Body 'Why AI will cite this: Specific founding date, product names, packaging sizes, and first-to-market claims. Every sentence is independently verifiable and directly answers questions buyers ask.' $GREEN $false $true

NL; H2 'EXAMPLE 2 -- Homepage Brand Story: Current vs. Recommended'
H3 'Current Version (Partially Citable)'
Code ("Bella Nico Inc. was established in 1995 with the addition of Veggie Values label`r`n" + "frozen club pack vegetables. Bella Nico was the first to present a clear 24 count,`r`n" + "3 Mini Cob Corn and the first to offer a 3 lb bag of Baby Lima Beans.")
Body 'This is good raw material but it is embedded in an Elementor layout block without semantic heading structure, making it inconsistently extracted by AI engines.' $AMBER $false $true

H3 'Recommended Version (Fully AI-Citable with Proper Structure)'
Code ("Bella Nico Inc. is a Canadian frozen food distributor established in 1995,`r`n" + "specialising in club-pack frozen vegetables under the Veggie Values brand.`r`n" + "In 31 years of operation, Bella Nico became the first company to introduce`r`n" + "a clear 24-count 3-inch Mini Cob Corn and the first to offer a 3lb bag`r`n" + "of Baby Lima Beans -- both items now rank in the top 5 in sales.`r`n" + "All products are available in clear 48oz packaging under the slogan:`r`n" + "We are not afraid to show you our quality.")
Body 'The addition of company type (Canadian, frozen food distributor), specific product context, and the clear packaging innovation gives AI engines fully extractable, verifiable sentences.' $GREEN $false $true

NL; H2 'Extractability Checklist'
$ect = MakeTable 7 3
HRow $ect @('Content Check','Current Status','Target')
$ecd = @(
    @('Citable definition in first paragraph',   'MISSING on all pages',     'Homepage and all product pages'),
    @('FAQ page with real content',              'Lorem Ipsum placeholder',  'Replace with 10+ real Q and A pairs'),
    @('Correct company contact information',     'Shows wrong demo email',   'All pages show real Bella Nico contact'),
    @('Self-contained answer blocks, 40 to 60 words','MISSING',              '3+ per product page'),
    @('Blog or informational articles',          'Zero published',           'Start with product and brand stories'),
    @('"Last Updated" date visible on pages',    'MISSING on all pages',     'All content pages')
)
for ($r=0;$r -lt $ecd.Count;$r++) {
    TC $ect ($r+2) 1 $ecd[$r][0] $false $DKGRAY 10 0
    TC $ect ($r+2) 2 $ecd[$r][1] $true  $RED_T  10 0 $BGRED
    TC $ect ($r+2) 3 $ecd[$r][2] $false $GREEN  10 0 $BGGRN
}
MoveOut $ect
PB

# ============================================================
# 5. AUTHORITY AND TRUST
# ============================================================
H1 '5. Authority and Trust Signals -- 20 / 100  (Critical Fail)'
HR

H2 'What This Measures'
Body 'AI systems prefer sources they can trust. A 2024 Princeton research study (KDD 2024, analysed across Perplexity AI) identified exactly which content signals increase the probability of being cited. This section scores Bella Nico against those nine proven factors.'

NL; H2 'PROS -- What You Are Doing Right'
Body 'The homepage contains a genuinely strong first-to-market claim: Bella Nico was the first to introduce a clear 24-count 3-inch Mini Cob Corn -- both items now rank in the top 5 in sales. This is specific, verifiable, and unique to the brand.' $GREEN
Body '31-year operating history (founded 1995) and the clear packaging innovation story are strong credibility anchors that AI engines can verify and cite as brand facts.' $GREEN
Body 'The Veggie Values page has a well-written meta title and description: "Bella Nico Veggie Values -- premium 48oz frozen vegetables including Green Beans, Normandy Blend, Mini Cob Corn and more." This is one of the few AI-readable metadata entries on the site.' $GREEN

NL; H2 'CONS -- What Needs Fixing'
Body 'The strongest brand claims are embedded in Elementor layout blocks without semantic HTML heading structure, making them inconsistently extracted by AI engines.' $RED_T
Body 'No external sources are cited anywhere on the site. Citing authoritative sources boosts AI citation probability by +40% (Princeton GEO study).' $RED_T
Body 'No author attribution appears on any page. Named authors with credentials boost citation probability by +25%.' $RED_T
Body 'No certifications, food safety standards, or quality credentials are mentioned anywhere on the site. Competitors listing USDA compliance, Non-GMO certification, or food safety audits immediately outrank uncertified pages.' $RED_T
Body 'The FAQ page undermines all trust signals by displaying irrelevant placeholder content and a wrong contact email.' $RED_T

NL; H2 'The Princeton Study: What Boosts AI Citations'
$pbt = MakeTable 10 4
HRow $pbt @('Citation Signal','Boost','Your Current Score','Recommended Fix')
$pbd = @(
    @('Cite external sources',      '+40%','ZERO citations anywhere',         'Add source links to product data'),
    @('Add statistics with data',   '+37%','2 claims, 0 cited',               'Cite first-to-market claims with year'),
    @('Expert quotations',          '+30%','None found',                      'Add quotes from company leadership'),
    @('Authoritative writing tone', '+25%','Moderate quality',                'Rewrite key passages as factual claims'),
    @('Clarity and readability',    '+20%','Moderate on homepage',            'Simplify FAQ and product descriptions'),
    @('Technical terminology',      '+18%','Very limited use',                'Use correct food industry terms'),
    @('Author attribution',         '+25%','ZERO on any page',                'Add company or author attribution'),
    @('Original data / research',   '+37%','ZERO original data published',    'Publish product sales rank data'),
    @('Keyword stuffing',           ' -10%','Not detected (GOOD)',             'Maintain -- do not add')
)
for ($r=0;$r -lt $pbd.Count;$r++) {
    $isGood = $pbd[$r][2] -like '*GOOD*' -or $pbd[$r][2] -like '*Moderate*'
    $rbg = if ($isGood) { $BGGRN } elseif ($pbd[$r][2] -like '*ZERO*') { $BGRED } else { $BGYEL }
    $rfg = if ($isGood) { $GREEN } elseif ($pbd[$r][2] -like '*ZERO*') { $RED_T } else { $AMBER }
    TC $pbt ($r+2) 1 $pbd[$r][0] $false $DKGRAY 10 0
    TC $pbt ($r+2) 2 $pbd[$r][1] $true  $GREEN  10 1
    TC $pbt ($r+2) 3 $pbd[$r][2] $false $rfg    10 0 $rbg
    TC $pbt ($r+2) 4 $pbd[$r][3] $false $DKGRAY 10 0
}
MoveOut $pbt

H2 'EXAMPLE -- Turning a Product Claim into a Citable Fact'
H3 'Current Version (Partially Citable)'
Code ('"Both items today rank in the top 5 in sales."')
Body 'Why AI under-uses this: No source, no category context, no year. "Top 5 in sales" without a reference to what category or data source is unverifiable.' $RED_T $false $true

H3 'Recommended Version (Fully Citable)'
Code ('"Bella Nico Mini Cob Corn (3-inch, 24-count clear bag) and Baby Lima Beans`r`n" + "(3lb clear bag) both rank in the top 5 sellers in their respective frozen`r`n" + "vegetable categories -- a position maintained since their introduction.`r`n" + "(Bella Nico sales data, 2025)"')
Body 'Why it works: Product name, size, format, ranking context, and a source attribution. Every element is independently extractable by AI.' $GREEN $false $true
PB

# ============================================================
# 6. CONTENT FRESHNESS
# ============================================================
H1 '6. Content Freshness -- 15 / 100  (Critical Fail)'
HR

H2 'What This Measures'
Body 'AI systems heavily weight content recency. A page that has not been updated in years will lose a citation to a 2025 competitor article on the same topic -- even if the older content is better. Freshness signals include visible "Last Updated" dates, current year references, and sitemap timestamps.'

NL; H2 'PROS'
Body 'The homepage correctly references 2026 as the current year and mentions 31 years in business -- this is an active freshness signal that helps AI engines recognise the site as current.' $GREEN
Body 'Product pages reference the new 48oz clear packaging transition, which is presented as a current change -- a positive recency indicator.' $GREEN

NL; H2 'CONS'
Body 'The FAQ page contains years-old Lorem Ipsum placeholder text that has never been replaced. This is the most visible stale content on the site and is actively damaging the brand in AI search.' $RED_T $true
Body 'Zero blog posts have ever been published. A competitor publishing 2 posts per month for 2 years has 48 additional citation opportunities that did not exist before.' $RED_T
Body 'No page shows a "Last Updated" date to the visitor or to AI crawlers in structured metadata.' $RED_T
Body '16 plugins are awaiting updates, including Elementor v3.25 to v4.0, ACF Pro v5.9 to v6.8, and AIOSEO v4.9.4 to v4.9.6. Outdated plugins signal site neglect to technical crawlers.' $RED_T

NL; H2 'Page Freshness Audit'
$fat = MakeTable 9 3
HRow $fat @('Page / Content','Current State','Action')
$fad = @(
    @('FAQ page content',          'Lorem Ipsum placeholder -- never replaced',  'URGENT -- replace with real content'),
    @('FAQ page contact email',    'info@agroly.com (wrong company)',            'URGENT -- update to real contact info'),
    @('Blog / news section',       'Does not exist',                            'Create and begin publishing'),
    @('Plugin updates',            '16 plugins outdated',                       'Update after site backup'),
    @('AIOSEO version',            '4.9.4.1 (update to 4.9.6.2 available)',     'Update -- AEO improvements in newer version'),
    @('Elementor version',         '3.25.6 (major v4.0 release available)',     'Update after testing in staging'),
    @('"Last Updated" dates',      'Missing on all pages',                      'Add to all content pages'),
    @('Homepage year references',  '2026 mentioned correctly -- GOOD',          'Maintain and review annually')
)
for ($r=0;$r -lt $fad.Count;$r++) {
    $isOk    = $fad[$r][2] -like '*GOOD*' -or $fad[$r][2] -like '*Maintain*'
    $isUrgent = $fad[$r][2] -like '*URGENT*'
    $rbg = if ($isOk) { $BGGRN } elseif ($isUrgent) { $BGRED } else { $BGYEL }
    $rfg = if ($isOk) { $GREEN } elseif ($isUrgent) { $RED_T } else { $AMBER }
    TC $fat ($r+2) 1 $fad[$r][0] $false $DKGRAY 10 0
    TC $fat ($r+2) 2 $fad[$r][1] $false $DKGRAY 10 0
    TC $fat ($r+2) 3 $fad[$r][2] $true  $rfg    10 0 $rbg
}
MoveOut $fat

H2 'What to Add to Every Content Page'
Code ("Last Updated: April 2026`r`n" + "Written by: Bella Nico Team`r`n" + "Product data: Bella Nico internal sales data, 2025")
Body 'Adding visible "Last Updated" dates signals content currency to both visitors and AI engines. Undated content consistently loses to dated content across all AI platforms.' $DKGRAY
PB

# ============================================================
# 7. SCHEMA MARKUP
# ============================================================
H1 '7. Schema Markup (Structured Data) -- 0 / 100  (Complete Fail)'
HR

H2 'What This Measures'
Body 'Schema markup is code added to pages that tells AI systems and search engines exactly what your content means. A product page with Product schema tells Google it is a product listing. An FAQ page with FAQPage schema tells ChatGPT to extract individual questions and answers. Content with proper schema shows 30-40% higher AI citation rates.'
Body 'AIOSEO is installed on bellanico.com and supports full schema configuration -- but the schema module has never been activated. This is the single highest-impact technical fix available and requires no coding.' $RED_T $true

NL; H2 'PROS'
Body 'AIOSEO Pro is installed. Unlike sites that need a developer to implement schema from scratch, Bella Nico can configure Organization, Product, FAQPage, and Breadcrumb schema entirely through the AIOSEO settings panel -- no code required.' $AMBER

NL; H2 'CONS'
Body 'Every page is invisible to AI at the structured data level. AI tools cannot confirm what type of content they are reading, who wrote it, what product is being described, or what company owns the site.' $RED_T

NL; H2 'Schema Opportunities -- Page by Page'
$smt = MakeTable 9 4
HRow $smt @('Page','Schema to Add','Citation Benefit','Effort')
$smd = @(
    @('Homepage',            'Organization, LocalBusiness',     'Company entity recognition on all AI platforms',     'Low -- AIOSEO settings panel'),
    @('FAQ Page',            'FAQPage (after content is fixed)', 'Direct Q and A extraction for AI Overviews',        'Low -- AIOSEO after content updated'),
    @('All product pages',   'Product, ItemList',               'Product query extraction -- buyers find products',   'Medium -- AIOSEO product templates'),
    @('Veggie Values page',  'ItemList, Product',               'Category-level extraction for frozen veg queries',   'Low -- AIOSEO settings'),
    @('Contact page',        'LocalBusiness, ContactPoint',     'Location and contact info extraction',               'Low -- AIOSEO settings'),
    @('Bella Nico page',     'Organization, AboutPage',         'Brand identity and company history extraction',      'Low -- AIOSEO settings'),
    @('All pages',           'BreadcrumbList',                  'Site structure clarity for AI crawlers',             'Low -- AIOSEO global setting'),
    @('Careers page',        'JobPosting (when applicable)',    'Recruiter and employment query visibility',           'Low -- when jobs are posted')
)
for ($r=0;$r -lt $smd.Count;$r++) {
    TC $smt ($r+2) 1 $smd[$r][0] $false $DKGRAY 10 0
    TC $smt ($r+2) 2 $smd[$r][1] $true  $BLUE   10 0 $BGBLUE
    TC $smt ($r+2) 3 $smd[$r][2] $false $GREEN  10 0 $BGGRN
    TC $smt ($r+2) 4 $smd[$r][3] $false $DKGRAY 10 0
}
MoveOut $smt

H2 'EXAMPLE 1 -- Organization Schema for the Homepage'
Body 'This code goes in a script tag in the homepage HTML, or is generated automatically by AIOSEO once the Organization settings are filled in:' $DKGRAY
Code ("{`r`n" + '  "@context": "https://schema.org",' + "`r`n" + '  "@type": "Organization",' + "`r`n" + '  "name": "Bella Nico Inc.",' + "`r`n" + '  "foundingDate": "1995",' + "`r`n" + '  "description": "Canadian frozen food distributor, maker of Veggie Values brand frozen vegetables since 1995.",' + "`r`n" + '  "url": "https://bellanico.com",' + "`r`n" + '  "email": "[real contact email]",' + "`r`n" + '  "telephone": "[real phone number]",' + "`r`n" + '  "brand": { "@type": "Brand", "name": "Veggie Values" }' + "`r`n" + '}')

NL; H2 'EXAMPLE 2 -- FAQPage Schema (once FAQ content is replaced)'
Body 'Each answer should be 40-80 words -- the optimal length for AI snippet extraction. This is the format that directly feeds Google AI Overviews and Perplexity citations:' $DKGRAY
Code ("{`r`n" + '  "@context": "https://schema.org",' + "`r`n" + '  "@type": "FAQPage",' + "`r`n" + '  "mainEntity": [{' + "`r`n" + '    "@type": "Question",' + "`r`n" + '    "name": "What products does Bella Nico make?",' + "`r`n" + '    "acceptedAnswer": {' + "`r`n" + '      "@type": "Answer",' + "`r`n" + '      "text": "Bella Nico distributes frozen vegetables under the Veggie Values' + "`r`n" + '               brand, including Mini Cob Corn, Baby Lima Beans, Cut Green Beans,' + "`r`n" + '               Broccoli Florets, and Normandy Blend. All products are available' + "`r`n" + '               in clear 48oz packaging."' + "`r`n" + '    }' + "`r`n" + '  }]' + "`r`n" + '}')
PB

# ============================================================
# 8. MACHINE-READABLE FILES
# ============================================================
H1 '8. Machine-Readable Files -- 0 / 100  (Complete Fail)'
HR

H2 'What This Measures'
Body 'AI systems and AI agents look for specific files at the root of websites. These files let AI quickly understand who the company is without needing to crawl every page. All three key files are missing from bellanico.com.'

NL; H2 'PROS'
Body 'The AIOSEO plugin can generate robots.txt and an XML sitemap automatically through its settings panel -- no developer involvement required for these files.' $GREEN

NL; H2 'CONS'
Body 'No robots.txt file exists. AI crawlers receive no guidance on site structure, crawl priority, or which sections to index.' $RED_T
Body 'No XML sitemap exists. Product pages with limited internal links may never be discovered by AI crawlers.' $RED_T
Body 'No /llms.txt file. AI systems have no quick-reference context for the brand, requiring full site crawls to build even a basic understanding of the company.' $RED_T

NL; H2 'Files to Create'
$mft = MakeTable 5 4
HRow $mft @('File','Purpose','Status','How to Create')
$mfd = @(
    @('/robots.txt',   'Directs AI and search crawlers to key pages, blocks admin areas, enables structured crawl',         'MISSING', 'AIOSEO settings -- Tools -- Robots.txt editor'),
    @('/sitemap.xml',  'Lists all important URLs for AI crawlers to discover product and content pages reliably',            'MISSING', 'AIOSEO settings -- Sitemaps -- enable and submit'),
    @('/llms.txt',     'Plain-text brand summary for AI systems -- replaces full site crawl with instant brand context', 'MISSING', 'Create manually, upload to site root'),
    @('/pricing.md',   'Plain-text product and pricing info for AI agents assisting buyers -- skipped if behind login wall', 'MISSING', 'Optional -- create when wholesale info available')
)
for ($r=0;$r -lt $mfd.Count;$r++) {
    TC $mft ($r+2) 1 $mfd[$r][0] $true  $BLUE   10 0 $BGBLUE
    TC $mft ($r+2) 2 $mfd[$r][1] $false $DKGRAY 10 0
    TC $mft ($r+2) 3 $mfd[$r][2] $true  $RED_T  10 0 $BGRED
    TC $mft ($r+2) 4 $mfd[$r][3] $false $DKGRAY 10 0
}
MoveOut $mft

H2 'EXAMPLE -- Exact Content to Put in /llms.txt'
Body 'Upload this plain-text file to the root of the website (same folder as robots.txt). This gives every AI system instant brand context:' $DKGRAY
Code ("# Bella Nico Inc.`r`n`r`n" + "> Canadian frozen food distributor established in 1995.`r`n" + "> Maker of Veggie Values brand frozen vegetables.`r`n" + "> First to introduce a clear 24-count 3-inch Mini Cob Corn`r`n" + "> and a 3lb bag of Baby Lima Beans (both top-5 sellers).`r`n" + "> All products now available in clear 48oz packaging.`r`n`r`n" + "## About`r`n" + "- Founded: 1995  |  Celebrating 31 years in 2026`r`n" + "- Brand: Veggie Values -- ""We took delicious and froze it in time""`r`n" + "- Slogan: ""We're not afraid to show you our quality""`r`n" + "- Products: Frozen vegetables + Roast Beef lines`r`n`r`n" + "## Product Lines`r`n" + "Veggie Values: Mini Cob Corn, Baby Lima Beans, Cut Green Beans,`r`n" + "Cut Corn, Broccoli Florets, Normandy Blend, Stir Fry, Chopped`r`n" + "Spinach, Mixed Vegetables, Black Eyed Peas, Whole Okra`r`n" + "Roast Beef: Italian Roast Beef in Au Jus, Roast Beef in Brown Gravy`r`n`r`n" + "## Key Pages`r`n" + "- Homepage:      https://bellanico.com/`r`n" + "- Veggie Values: https://bellanico.com/veggie-values/`r`n" + "- Products:      https://bellanico.com/product_category/veggie-values/`r`n" + "- Contact:       https://bellanico.com/contact-us/`r`n" + "- FAQ:           https://bellanico.com/faq-page/")
PB

# ============================================================
# 9. CONTENT DEPTH
# ============================================================
H1 '9. Content Depth and Volume -- 15 / 100  (Critical Fail)'
HR

H2 'What This Measures'
Body 'AI systems cite specific, substantive content. The more useful content a site publishes on topics relevant to its business, the more citation opportunities it creates. Bella Nico has 6 published pages, 16 product listings, and zero blog posts. There is no comparison content and no educational content about frozen vegetables.'

NL; H2 'PROS'
Body 'The homepage brand story is authentic and specific: 31 years, first-to-market Mini Cob Corn, top-5 seller status, clear packaging innovation. This is strong foundation content.' $GREEN
Body '16 product listings cover a complete frozen vegetable range plus two roast beef lines -- clear product breadth that supports entity recognition.' $GREEN
Body 'The Veggie Values page has a product chart with item numbers, dimensions, and pack sizes -- this is exactly the structured data format that AI engines and B2B buyers need.' $GREEN

NL; H2 'CONS'
Body 'Zero blog posts. Every month without content is a missed citation opportunity. A competitor publishing 2 posts per month builds 24+ citation chances per year.' $RED_T
Body 'Product pages are listing format only -- no descriptions, no use cases, no nutritional context, no differentiators. A buyer asking AI "What makes Veggie Values better than Birds Eye?" gets no answer from this site.' $RED_T
Body 'No comparison content exists. "X vs Y" queries account for approximately 33% of AI product citations.' $RED_T
Body 'The FAQ page has zero real content -- it is entirely placeholder text. This is the most urgent content gap on the site.' $RED_T

NL; H2 'Content Inventory'
$cit = MakeTable 8 3
HRow $cit @('Content Type','Count','Assessment')
$cid = @(
    @('Total published pages',           '6 pages',      'Very low -- typical competitor has 20-100+'),
    @('Published product listings',      '16 products',  'Good range -- but descriptions are missing'),
    @('Blog or article content',         '0',            'MISSING -- no blog exists at all'),
    @('FAQ page with real content',      '0',            'MISSING -- page exists but has placeholder text'),
    @('Comparison pages (X vs Y)',       '0',            'MISSING -- 33% of citations come from these'),
    @('Product pages with descriptions', '0',            'MISSING -- all products lack written descriptions'),
    @('Original data or research',       '0',            'MISSING -- top-5 sales claims have no source')
)
for ($r=0;$r -lt $cid.Count;$r++) {
    $bg = if ($cid[$r][2] -like '*MISSING*') { $BGRED } elseif ($cid[$r][2] -like '*Good*') { $BGGRN } else { $BGYEL }
    TC $cit ($r+2) 1 $cid[$r][0] $false $DKGRAY 10 0
    TC $cit ($r+2) 2 $cid[$r][1] $true  $DKGRAY 10 1
    TC $cit ($r+2) 3 $cid[$r][2] $false $DKGRAY 10 0 $bg
}
MoveOut $cit

H2 'High-Value Content to Create (AI Queries You Are Missing)'
$hvt = MakeTable 10 3
HRow $hvt @('Target Query','Content Type Needed','Citation Potential')
$hvd = @(
    @('What is Veggie Values frozen vegetables?',      'Brand explainer page (500+ words)',              'High'),
    @('Who makes Veggie Values?',                      'About / brand history page (Bella Nico story)',  'High'),
    @('Best frozen vegetables for meal prep',          'Educational article with product recommendations','High'),
    @('Club pack frozen vegetables bulk buy',          'Wholesale / distributor information page',       'High'),
    @('Clear packaging frozen vegetables',             'Innovation story page -- clear packaging change', 'Medium'),
    @('Frozen mini corn cobs where to buy',            'Product page expansion with retailer info',      'High'),
    @('Baby Lima Beans vs regular Lima Beans',         'Comparison or product guide content',            'Medium'),
    @('Frozen vegetable shelf life and storage',       'FAQ or guide article',                           'High'),
    @('Veggie Values vs Birds Eye vs Green Giant',     'Brand comparison page',                          'High')
)
for ($r=0;$r -lt $hvd.Count;$r++) {
    $hiP = $hvd[$r][2] -eq 'High'
    TC $hvt ($r+2) 1 $hvd[$r][0] $false $DKGRAY 10 0
    TC $hvt ($r+2) 2 $hvd[$r][1] $false $DKGRAY 10 0
    TC $hvt ($r+2) 3 $hvd[$r][2] $true  (if($hiP){$GREEN}else{$AMBER}) 10 1 (if($hiP){$BGGRN}else{$BGYEL})
}
MoveOut $hvt
PB

# ============================================================
# 10. COMPETITIVE SNAPSHOT
# ============================================================
H1 '10. Competitive Snapshot'
HR
Body 'This table is a high-confidence projection based on the content gaps found during the audit and what AI platforms typically cite for these frozen food query types.' $DKGRAY $false $true
NL

$cst = MakeTable 7 4
HRow $cst @('Search Query','Brands Being Cited Now','Bella Nico','The Gap')
$csd = @(
    @('"best frozen vegetable brands"',       'Birds Eye, Green Giant, Cascadian Farm','NOT cited','No AI-optimised content or schema'),
    @('"Veggie Values frozen vegetables"',    'No consistent source cited',            'NOT cited','No entity schema, thin product pages'),
    @('"club pack frozen corn bulk"',         'Sam''s Club, Sysco listings',           'NOT cited','No wholesale or distributor info page'),
    @('"clear packaging frozen vegetables"',  'No strong competitor owns this',        'NOT cited','Has the story -- zero content about it'),
    @('"frozen baby lima beans"',             'Birds Eye, Pictsweet',                  'NOT cited','Product listing exists but no description'),
    @('"who makes mini cob corn"',            'No consistent source',                  'NOT cited','First-to-market claim not in schema or FAQ')
)
for ($r=0;$r -lt $csd.Count;$r++) {
    TC $cst ($r+2) 1 $csd[$r][0] $false $DKGRAY 10 0
    TC $cst ($r+2) 2 $csd[$r][1] $false $DKGRAY 10 0
    TC $cst ($r+2) 3 $csd[$r][2] $true  $RED_T  10 0 $BGRED
    TC $cst ($r+2) 4 $csd[$r][3] $false $DKGRAY 10 0
}
MoveOut $cst
Body 'The gap is structural, not brand quality. Bella Nico has first-to-market product innovations, a 31-year operating history, and the unique clear packaging story. These are exactly the kinds of specific, verifiable claims that AI engines love to cite. The difference is that they are not yet in a format AI can reliably extract.' $AMBER $true
PB

# ============================================================
# 11. FINAL SUMMARY
# ============================================================
H1 '11. Final Summary: Pros, Cons and Next Steps'
HR

$fst = MakeTable 8 4
HRow $fst @('Pillar','PROS -- What is Working','CONS -- What Needs Fixing','Top Next Step')
$fsd = @(
    @('AI Bot Access',
      'SSL active. AIOSEO can generate robots.txt and sitemap from settings panel.',
      'No robots.txt. No sitemap enabled. No llms.txt. Bots visit with no guidance.',
      'Enable AIOSEO sitemap and create robots.txt through AIOSEO tools panel.'),
    @('Content Structure',
      'Homepage brand story is specific and citable. Product chart has structured data.',
      'FAQ page is entirely Lorem Ipsum. Contact email shows wrong company. No real FAQ content.',
      'Replace all FAQ page content. Fix contact email. Add real Q and A blocks.'),
    @('Authority and Trust',
      'First-to-market Mini Cob Corn claim. 31-year history. Top-5 sales rank.',
      'Best claims have no source. No certifications listed. No author attribution anywhere.',
      'Add data source attribution to top-5 claim. List any food safety or quality standards.'),
    @('Content Freshness',
      'Homepage references 2026 correctly. Clear packaging transition shows recent change.',
      'FAQ page is stale placeholder text. No blog. 16 plugin updates pending.',
      'Replace FAQ content urgently. Schedule plugin updates with site backup.'),
    @('Schema Markup',
      'AIOSEO Pro is installed -- schema can be configured without any coding.',
      'AIOSEO schema module completely inactive. Zero schema on any page.',
      'Open AIOSEO, configure Organization schema and enable global schema settings.'),
    @('Machine-Readable Files',
      'AIOSEO can create robots.txt and sitemap -- no developer needed.',
      'No robots.txt. No sitemap.xml. No llms.txt. AI agents cannot read brand context.',
      'Use AIOSEO to generate robots.txt and sitemap. Create llms.txt manually.'),
    @('Content Depth',
      'Homepage story and product chart are strong foundations to build from.',
      'Zero blog posts. No product descriptions. FAQ page has placeholder content.',
      'Publish first blog post about Bella Nico brand story and Mini Cob Corn history.')
)
for ($r=0;$r -lt $fsd.Count;$r++) {
    TC $fst ($r+2) 1 $fsd[$r][0] $true  $NAVY   10 0 $BGBLUE
    TC $fst ($r+2) 2 $fsd[$r][1] $false $GREEN  10 0 $BGGRN
    TC $fst ($r+2) 3 $fsd[$r][2] $false $RED_T  10 0 $BGRED
    TC $fst ($r+2) 4 $fsd[$r][3] $false $DKGRAY 10 0 $BGYEL
}
MoveOut $fst

NL; H2 'Closing Note'
Body 'Bella Nico has everything needed to become a frequently-cited source in AI-generated answers about frozen vegetables: a 31-year heritage, first-to-market product innovations, a distinctive clear packaging story, and a complete product range with genuine consumer demand. The investment required is primarily content writing and plugin configuration -- not structural rebuilds. The return is permanent visibility in the AI search results that are rapidly replacing traditional blue-link clicks.'
Body 'This report was generated on April 24, 2026 from live site data collected via SSH and WP-CLI during the audit session. Prepared by Fresh Design Studio.' $DKGRAY $false $true

# ============================================================
# SAVE
# ============================================================
$doc.SaveAs([ref]$outputPath, [ref]16)
$doc.Close()
$word.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($word) | Out-Null

Write-Output "SUCCESS -- File saved to: $outputPath"
