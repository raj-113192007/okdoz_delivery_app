<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:html="http://www.w3.org/TR/REC-html40"
                xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
                xmlns:sitemap="http://www.sitemaps.org/schemas/sitemap/0.9"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" version="1.0" encoding="UTF-8" indent="yes"/>
  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>XML Sitemap | KrypZen Ecosystem</title>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <style type="text/css">
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen-Sans, Ubuntu, Cantarell, "Helvetica Neue", sans-serif;
            color: #334155;
            background-color: #0f172a;
            margin: 0;
            padding: 40px 20px;
          }
          .container {
            max-width: 1000px;
            margin: 0 auto;
            background: #1e293b;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5), 0 8px 10px -6px rgba(0, 0, 0, 0.5);
            border: 1px solid #334155;
          }
          h1 {
            color: #f8fafc;
            font-size: 24px;
            margin-top: 0;
            margin-bottom: 8px;
            font-weight: 700;
          }
          p.desc {
            color: #94a3b8;
            font-size: 14px;
            margin-bottom: 24px;
          }
          .stats {
            display: flex;
            gap: 16px;
            margin-bottom: 24px;
          }
          .stat-card {
            background: #0f172a;
            padding: 12px 20px;
            border-radius: 8px;
            border: 1px solid #334155;
          }
          .stat-value {
            color: #38bdf8;
            font-size: 20px;
            font-weight: 700;
          }
          .stat-label {
            color: #64748b;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.05em;
          }
          table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
          }
          th {
            background: #0f172a;
            color: #94a3b8;
            font-weight: 600;
            text-align: left;
            padding: 12px 16px;
            border-bottom: 2px solid #334155;
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.05em;
          }
          td {
            padding: 12px 16px;
            border-bottom: 1px solid #334155;
            color: #cbd5e1;
          }
          tr:hover td {
            background-color: #273549;
          }
          a {
            color: #38bdf8;
            text-decoration: none;
            word-break: break-all;
          }
          a:hover {
            text-decoration: underline;
          }
          .badge-prio {
            background: rgba(56, 189, 248, 0.15);
            color: #38bdf8;
            padding: 2px 8px;
            border-radius: 9999px;
            font-weight: 600;
            font-size: 11px;
          }
          .badge-freq {
            background: rgba(148, 163, 184, 0.15);
            color: #94a3b8;
            padding: 2px 8px;
            border-radius: 9999px;
            font-size: 11px;
          }
          .badge-img {
            background: rgba(74, 222, 128, 0.15);
            color: #4ade80;
            padding: 2px 8px;
            border-radius: 9999px;
            font-size: 11px;
          }
        </style>
      </head>
      <body>
        <div class="container">
          <h1>⚡ High-Performance XML Sitemap</h1>
          <p class="desc">Engineered for Googlebot, Bingbot, IndexNow, and Next-Gen Search Engines.</p>
          
          <div class="stats">
            <div class="stat-card">
              <div class="stat-value"><xsl:value-of select="count(sitemap:urlset/sitemap:url)"/></div>
              <div class="stat-label">Total Indexed URLs</div>
            </div>
            <div class="stat-card">
              <div class="stat-value"><xsl:value-of select="count(sitemap:urlset/sitemap:url/image:image)"/></div>
              <div class="stat-label">Image Assets</div>
            </div>
          </div>

          <table>
            <thead>
              <tr>
                <th width="50%">Page URL</th>
                <th width="12%">Priority</th>
                <th width="15%">Change Freq</th>
                <th width="13%">Images</th>
                <th width="10%">Last Modified</th>
              </tr>
            </thead>
            <tbody>
              <xsl:for-each select="sitemap:urlset/sitemap:url">
                <tr>
                  <td>
                    <a target="_blank">
                      <xsl:attribute name="href">
                        <xsl:value-of select="sitemap:loc"/>
                      </xsl:attribute>
                      <xsl:value-of select="sitemap:loc"/>
                    </a>
                  </td>
                  <td>
                    <span class="badge-prio"><xsl:value-of select="sitemap:priority"/></span>
                  </td>
                  <td>
                    <span class="badge-freq"><xsl:value-of select="sitemap:changefreq"/></span>
                  </td>
                  <td>
                    <xsl:if test="image:image">
                      <span class="badge-img"><xsl:value-of select="count(image:image)"/> Images</span>
                    </xsl:if>
                  </td>
                  <td><xsl:value-of select="sitemap:lastmod"/></td>
                </tr>
              </xsl:for-each>
            </tbody>
          </table>
        </div>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
