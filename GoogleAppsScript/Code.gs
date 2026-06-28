// Adventure Wear – Google Apps Script Web App
// Deploy: Extensions → Apps Script → Deploy → New deployment
//   Type: Web app | Execute as: Me | Who has access: Anyone
// After deploying, copy the Web App URL into Secrets.plist in the iOS project.
//
// Before deploying, set Script Properties (Project Settings → Script Properties):
//   SPREADSHEET_ID  — the ID from your Google Sheet URL
//   TOKEN           — any secret string; must match SheetsToken in Secrets.plist

const SHEET_NAME = 'Entries';

function getConfig_() {
  const props = PropertiesService.getScriptProperties();
  return {
    spreadsheetId: props.getProperty('SPREADSHEET_ID'),
    token:         props.getProperty('TOKEN'),
  };
}

const COLUMNS = [
  'timestamp', 'activity', 'temp', 'feelsLike', 'conditions', 'wind', 'humidity',
  'timeOfDay', 'teeTime', 'lowTemp', 'highTemp', 'wetGround',
  'outerwear', 'topLong', 'topShort', 'bottoms', 'head', 'hands', 'feet',
  'notes', 'courseName'
];

function doGet(e) {
  const { spreadsheetId, token } = getConfig_();
  const params = e.parameter;
  if (params.token !== token) return jsonResponse({ error: 'Unauthorized' });

  const sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName(SHEET_NAME);
  if (!sheet) return jsonResponse({ error: 'Sheet not found' });

  const data = sheet.getDataRange().getValues();
  if (data.length < 2) return jsonResponse([]);

  const headers = data[0];
  const colIndex = (name) => headers.indexOf(name);

  const activity = params.activity;
  const minTemp = parseFloat(params.minTemp);
  const maxTemp = parseFloat(params.maxTemp);

  const results = data.slice(1)
    .filter(row => {
      const rowActivity = String(row[colIndex('activity')] ?? '');
      const rowTemp = parseFloat(row[colIndex('temp')]);
      return rowActivity === activity && !isNaN(rowTemp) && rowTemp >= minTemp && rowTemp <= maxTemp;
    })
    .map(row => {
      const obj = {};
      headers.forEach((h, i) => { obj[h] = String(row[i] ?? ''); });
      return obj;
    });

  return jsonResponse(results);
}

function doPost(e) {
  const { spreadsheetId, token } = getConfig_();
  const body = JSON.parse(e.postData.contents);
  if (body.token !== token) return jsonResponse({ error: 'Unauthorized' });

  const sheet = SpreadsheetApp.openById(spreadsheetId).getSheetByName(SHEET_NAME);
  if (!sheet) return jsonResponse({ error: 'Sheet not found' });

  const row = COLUMNS.map(col => body[col] ?? '');
  sheet.appendRow(row);

  return jsonResponse({ status: 'ok' });
}

function jsonResponse(data) {
  return ContentService
    .createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON);
}
