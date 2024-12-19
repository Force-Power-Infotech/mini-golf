// APIs root url = https://script.google.com/macros/s/AKfycbwy-p8bwLNYWLzfs7UYDP24MTtQN9LWgPg3Gxiv_q3iIGFWfMoO0tja3M2BfoCDS7ASww/exec

// Mini Golf Master Book ID
var masterbookID = "10sW-HrJkP4mcDiZP8HqOV8SS8xyx42vnQTOpd7bD008";

// Table Structures
// users - uid	mobileNo	otp	name	lastLogin	active
// teams - teamId	createdBy	members	LastUpdated
// score - uid	teamId	score	status  LastUpdated

var usersSheet = 'users';

// GET http protocol reciever
function doGet(req) {
  var query = req.parameter.q;
  switch (query) {
    case "leaderboard":
      return leaderboard(req.parameter);
    case "latestLeaderboard":
      return getLatestTeamLeaderboard();
    case "dayWiseLeaderboard":
      return getDayWiseLeaderboard();
    default:
      var response = {
        "error": true,
        "message": "This is invalid Request"
      };
      return responseJSON(response);
  }
}

// POST http protocol reciever
function doPost(req) {
  var query = req.parameter.q;
  var action = req.parameter.a;
  switch (query) {
    case "login":
      return login(req.parameter);
    case "verifyOTP":
      return verifyOTP(req.parameter);
    case "createTeam":
      return createTeam(req.parameter);
    case "scoring":
      return scoring(req.parameter);
    case "leaderboard":
      return leaderboard(req.parameter);
    case "latestLeaderboard":
      return getLatestTeamLeaderboard();
    case "dayWiseLeaderboard":
      return getDayWiseLeaderboard();
    default:
      response = {
        "error": true,
        "message": "This is invalid Request"
      };
      return responseJSON(response);
  }
}

// login
function login(parameter) {
  var mobileNo = parameter.mobileNo;
  // checking if mobile number is valid
  if (mobileNo.length != 10) {
    var message = {
      "error": true,
      "message": "Mobile Number is invalid"
    };
    return responseJSON(message);
  } else {
    // Open Masterbook to authenticate
    var masterbook = SpreadsheetApp.openById(masterbookID);
    // Open users sheets
    var mbUsers = masterbook.getSheetByName(usersSheet);
    // Getting index of mobileNo
    var mobileNoIndex = mbUsers.getSheetValues(2, 2, mbUsers.getLastRow() - 1, 1).map((value) => value[0].toString()).indexOf(mobileNo);
    // generating OTP
    var otp = Math.floor(1000 + Math.random() * 9000);
    otp = 1010;
    if (mobileNoIndex == -1) {
      // Writting Data to Master Book - Users
      var userID = Date.now();
      var lastLogin = new Date();
      var newData = [userID, mobileNo, otp, "", lastLogin, true];
      var lastRow = mbUsers.getLastRow();
      var writeRange = mbUsers.getRange(lastRow + 1, 1, 1, 6);
      writeRange.setValues([newData]);
      var message = {
        "error": false,
        "message": "New User, OTP Sent to your mobile number",
        "userID": userID,
      };
      return responseJSON(message);
    } else {
      // Getting details of the mobileNo
      var mobileNoDetails = mbUsers.getSheetValues(mobileNoIndex + 2, 1, 1, 6)[0];
      var activeHeaderIndex = mbUsers.getSheetValues(1, 1, 1, 6)[0].indexOf('active');
      // Updating OTP
      var lastLogin = new Date();
      mbUsers.getRange(mobileNoIndex + 2, 3).setValue(otp);
      mbUsers.getRange(mobileNoIndex + 2, 5).setValue(lastLogin);
      var name = mobileNoDetails[3];
      // Checking password of the request
      if (mobileNoDetails[activeHeaderIndex] == true) {
        var response = {
          "error": false,
          "message": "Hi ".concat(name, " OTP Sent to your mobile number"),
          "userID": mobileNoDetails[0],
        };
        return responseJSON(response);
      } else {
        var message = {
          "error": true,
          "message": "Hi ".concat(name, " Your account is not active")
        };
        return responseJSON(message);
      }
    }
  }
}

// verify OTP
function verifyOTP(parameter) {
  var userID = parameter.userID;
  var otp = parameter.otp;
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open users sheets
  var mbUsers = masterbook.getSheetByName(usersSheet);
  // Getting index of mobileNo
  var userIDIndex = mbUsers.getSheetValues(2, 1, mbUsers.getLastRow() - 1, 1).map((value) => value[0].toString()).indexOf(userID);
  // Checking if OTP is valid
  if (userIDIndex != -1) {
    var userDetails = mbUsers.getSheetValues(userIDIndex + 2, 1, 1, 6)[0];
    var otpIndex = mbUsers.getSheetValues(1, 1, 1, 6)[0].indexOf('otp');
    var activeIndex = mbUsers.getSheetValues(1, 1, 1, 6)[0].indexOf('active');
    if (userDetails[otpIndex] == otp) {
      var response = {
        "error": false,
        "message": "OTP Verified Successfully",
        "userID": userDetails[0],
        "mobileNo": userDetails[1],
        "otp": userDetails[2],
        "name": userDetails[3],
        "lastLogin": userDetails[4],
        "active": userDetails[5]
      };
      return responseJSON(response);
    } else {
      var message = {
        "error": true,
        "message": "OTP is invalid"
      };
      return responseJSON(message);
    }
  } else {
    var message = {
      "error": true,
      "message": "User not found"
    };
    return responseJSON(message);
  }
}

// create team
function createTeam(parameter) {
  var teamId = Date.now();
  var createdBy = parameter.createdBy;
  // members - Array of Strings
  var members = JSON.parse(parameter.members);
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open teams sheets
  var mbTeams = masterbook.getSheetByName('teams');
  // Get last Row
  var lastRow = mbTeams.getLastRow();
  // make user for each member
  var membersUid = [];
  var membersDetails = [];
  for (var i = 0; i < members.length; i++) {
    var member = members[i];
    var mbUsers = masterbook.getSheetByName(usersSheet);
    var userID = Date.now();
    var lastLogin = new Date();
    var newData = [userID, "Guest", "", member, lastLogin, true];
    var lastRow_mbUsers = mbUsers.getLastRow();
    var writeRange = mbUsers.getRange(lastRow_mbUsers + 1, 1, 1, 6);
    writeRange.setValues([newData]);
    membersUid.push(userID);
    membersDetails.push({
      "userID": userID,
      "userName": member,
    });
  }
  // set values
  var teamData = [teamId, createdBy, membersUid.join('/'), new Date()];
  var writeRange = mbTeams.getRange(lastRow + 1, 1, 1, 4);
  writeRange.setValues([teamData]);
  // response
  var response = {
    "error": false,
    "message": "Team Created Successfully",
    "teamId": teamId,
    "createdBy": createdBy,
    "members": membersDetails,
    "createDateTime": new Date()
  };
  return responseJSON(response);
}

// scoring
function scoring(parameter) {
  var uid = parameter.uid;
  var teamId = parameter.teamId;
  var score = parameter.score;
  var status = true;
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open score sheets
  var mbScore = masterbook.getSheetByName('score');
  // Get last Row
  var lastRow = mbScore.getLastRow();
  // search if the user has already scored
  var userScore = mbScore.getSheetValues(2, 1, mbScore.getLastRow(), mbScore.getLastColumn());
  // get the row numbers of the scores by team ID and uid
  var userScoreIndex = userScore.findIndex(function (v) {
    return v[0] == uid && v[1] == teamId;
  });
  // set values
  var scoreData = [uid, teamId, score, status, new Date()];
  if (userScoreIndex == -1) {
    var writeRange = mbScore.getRange(lastRow + 1, 1, 1, 5);
  } else {
    var writeRange = mbScore.getRange(userScoreIndex + 2, 1, 1, 5);
  }
  writeRange.setValues([scoreData]);
  // response
  var response = {
    "error": false,
    "message": "Score Added Successfully",
    "uid": uid,
    "teamId": teamId,
    "score": score,
    "status": status,
    "userScoreIndex": userScoreIndex,
    "userScore": userScore,
    "createDateTime": new Date()
  };
  return responseJSON(response);
}

// leaderboard
function leaderboard(parameter) {
  var teamId = parameter.teamId;
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open score sheets
  var mbScore = masterbook.getSheetByName('score');
  // get range of all the scores
  var getScores = mbScore.getRange(2, 1, mbScore.getLastRow(), mbScore.getLastColumn());
  // get all the scores
  var allScores = getScores.getValues();
  // get the row numbers of the scores by team ID
  var teamScores = allScores.filter(function (v) {
    return v[1] == teamId && v[2] != 0 && v[2] != "0"; // Filter team ID and exclude zeros
  });
  // sort the team scores
  teamScores.sort(function (a, b) {
    return a[2] - b[2];
  });
  var teamScores = teamScores.map(function (v) {
    return {
      "uid": v[0],
      "score": v[2],
      "status": v[3],
      "lastUpdated": v[4],
      "userName": playerName(v[0]),
    };
  });
  // response
  var response = {
    "error": false,
    "message": "Leaderboard",
    "teamId": teamId,
    "scores": teamScores
  };
  return responseJSON(response);
}

// day wise leaderboard
function getDayWiseLeaderboard() {
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open score sheets
  var mbScore = masterbook.getSheetByName('score');
  // get range of all the scores
  var getScores = mbScore.getRange(2, 1, mbScore.getLastRow(), mbScore.getLastColumn());
  // get all the scores
  var allScores = getScores.getValues();
  
  // Get today's date at midnight for comparison
  var today = new Date();
  today.setHours(0,0,0,0);
  
  // Filter scores for today only and exclude zeros
  var todayScores = allScores.filter(function(v) {
    var scoreDate = new Date(v[4]); // v[4] is lastUpdated
    scoreDate.setHours(0,0,0,0);
    return scoreDate.getTime() === today.getTime() && v[2] != 0 && v[2] != "0";
  });
  
  // Sort scores by highest first
  todayScores.sort(function(a, b) {
    return a[2] - b[2];
  });
  
  var formattedScores = todayScores.map(function(v) {
    return {
      "uid": v[0],
      "teamId": v[1],
      "score": v[2],
      "status": v[3],
      "lastUpdated": v[4],
      "userName": playerName(v[0])
    };
  });
  
  // response
  var response = {
    "error": false,
    "message": "Today's Leaderboard",
    "date": today.toISOString().split('T')[0],
    "scores": formattedScores
  };
  
  return responseJSON(response);
}

// player name from uid
function playerName(uid) {
  // Open Master Book
  var masterbook = SpreadsheetApp.openById(masterbookID);
  // Open users sheets
  var mbUsers = masterbook.getSheetByName(usersSheet);
  // Getting index of uid
  var userIDIndex = mbUsers.getSheetValues(2, 1, mbUsers.getLastRow() - 1, 1).map((value) => value[0]).indexOf(uid);
  if (userIDIndex != -1) {
    var userDetails = mbUsers.getSheetValues(userIDIndex + 2, 1, 1, 6)[0];
    return userDetails[3];
  } else {
    return "Guest";
  }
}

// Add this new function to get the latest team
function getLatestTeamID() {
  var masterbook = SpreadsheetApp.openById(masterbookID);
  var mbTeams = masterbook.getSheetByName('teams');
  var teams = mbTeams.getRange(2, 1, mbTeams.getLastRow() - 1, mbTeams.getLastColumn()).getValues();
  
  // Sort teams by creation date (last column) in descending order
  teams.sort(function(a, b) {
    return new Date(b[3]) - new Date(a[3]);
  });
  
  return teams.length > 0 ? teams[0][0].toString() : null;
}

// Add this new function for latest team leaderboard
function getLatestTeamLeaderboard() {
  var latestTeamId = getLatestTeamID();
  
  if (!latestTeamId) {
    return responseJSON({
      "error": true,
      "message": "No teams found"
    });
  }

  // Use existing leaderboard function with latest team ID
  return leaderboard({ teamId: latestTeamId });
}

// JSON response
function responseJSON(data) {
  return ContentService.createTextOutput(JSON.stringify(data))
    .setMimeType(ContentService.MimeType.JSON)
}