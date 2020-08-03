if (!(window.location.hostname == 'hackerone.com' &&
      (window.location.pathname.startsWith('/reports/') ||
       window.location.pathname.startsWith('/bugs')))) {
  alert('Unrecognized HackerOne report');
  return;
}

severity = document.querySelector('.report-heading.spec-report-heading .report-meta .spec-severity-rating').innerText;
reportURL = document.querySelector('.report-heading.spec-report-heading .report-status a.report-status-indicator').href;
title = document.querySelector('.report-heading.spec-report-heading .spec-report-title').innerText;
reporter = document.querySelector('.content-wrapper .spec-researcher-context .spec-mini-profile-name').innerText;
description = document.querySelector('.timeline .timeline-item .timeline-container .spec-vulnerability-information').innerText;

if (description.length > 4000) {
  description = description.substr(0, 4000) + `\n\n<i>CLIPPED</i> - see ${reportURL} for the full report.\n`;
}

body = `Severity: ${severity}\n
CVE: _TODO_\n
Original report: ${reportURL}\n
Current Status: planning\n
\n
Attribution: ${reporter}\n
\n
## Description\n
\n
<details><summary><i>Details</i></summary><p>\n\n
${description}\n
</p></details>\n
\n
## Release plan\n
Patch Process: _{Private, Stealth, Public}_\n
\n
_Needs embargo? Do we control the embargo?_\n
Target dates:\n
- embargo notification sent: YYYY-MM-DD\n
- public announcement: YYYY-MM-DD\n
\n
Vulnerable versions: _TODO_\n
Fixed versions: _TODO_`;
labels = `src/hackerone,severity/${severity.toLowerCase()}`;

repo = 'kubernetes-security/security-disclosures';
url = `https://github.com/${repo}/issues/new?body=${encodeURIComponent(body)}&title=${encodeURIComponent(title)}&labels=${labels}`;

let win = window.open(url, '_blank');
win.focus();
