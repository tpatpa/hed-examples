function errors = testEventServices(host)

%% Shows how to call hed-services to process a BIDS events file.
% 
%  Example 1: Validate valid events file using HED version.
%
%  Example 2: Validate invalid events file using a HED URL.
%
%  Example 3: Assemble valid event HED strings uploading HED schema.
%
%  Example 4: Assemble valid event HED strings (def expand) using HED version.
%
%  Example 5: Assemble valid event HED strings (no def expand) with extra columns.
%
%  Example 6: Generate a JSON sidecar template from an events file.


%% Get the options and data
[servicesUrl, options] = getHostOptions(host);
data = getTestData();
errors = {};

%% Example 1: Validate valid events file using HED version.
request1 = struct('service', 'events_validate', ...
                  'schema_version', '8.0.0', ...
                  'sidecar_string', data.jsonText, ...
                  'events_string', data.eventsText, ...
                  'check_for_warnings', 'off');
response1 = webwrite(servicesUrl, request1, options);
response1 = jsondecode(response1);
outputReport(response1, 'Example 1 validating a valid event file.');
if ~isempty(response1.error_type) || ...
   ~strcmpi(response1.results.msg_category, 'success')
   errors{end + 1} = 'Example 1 failed to validate a correct event file.';
end

%% Example 2: Validate invalid events file using a HED URL.
request2 = struct('service', 'events_validate', ...
                  'schema_url', data.schemaUrl, ...
                  'sidecar_string', data.jsonBadText, ...
                  'events_string', data.eventsText, ...
                  'check_for_warnings', 'off');

response2 = webwrite(servicesUrl, request2, options);
response2 = jsondecode(response2);
outputReport(response2, 'Example 2 validating events with invalid JSON.');
if ~isempty(response2.error_type) || ...
   ~strcmpi(response2.results.msg_category, 'warning')
   errors{end + 1} = ...
       'Example 2 failed to detect event file validation errors.';
end

%% Example 3: Assemble valid events file uploading a HED schema
request3 = struct('service', 'events_assemble', ...
                  'schema_string', data.schemaText, ...
                  'sidecar_string', data.jsonText, ...
                  'events_string', data.eventsText, ...
                  'columns_included', '', ...
                  'expand_defs', 'off');
request3.columns_included = {'onset'};
response3 = webwrite(servicesUrl, request3, options);
response3 = jsondecode(response3);
outputReport(response3, ...
    'Example 3 output for assembling valid events file');
if ~isempty(response3.error_type) || ...
   ~strcmpi(response3.results.msg_category, 'success')
   errors{end + 1} = 'Example 3 failed to assemble a correct events file.';
end

%%  Example 4: Assemble valid event HED strings(expand defs on).
request4 = struct('service', 'events_assemble', ...
                  'schema_version', '8.0.0', ...
                  'sidecar_string', data.jsonText, ...
                  'events_string', data.eventsText, ...
                  'expand_defs', 'on');
response4 = webwrite(servicesUrl, request4, options);
response4 = jsondecode(response4);
outputReport(response4, ...
    'Example 4 assembling HED annotations for events.');
if ~isempty(response4.error_type) || ...
   ~strcmpi(response4.results.msg_category, 'success')
   errors{end + 1} = ...
       'Example 4 failed to assemble events file with expand defs.';
end

%%  Example 5: Assemble valid event HED strings with additional columns.
columns_included = {'onset', 'face_type', 'rep_status'};
request5 = struct('service', 'events_assemble', ...
                  'schema_version', '8.0.0', ...
                  'sidecar_string', data.jsonText, ...
                  'events_string', data.eventsText, ...
                  'columns_included', '', ...
                  'expand_defs', 'off');
request5.columns_included = columns_included;
response5 = webwrite(servicesUrl, request5, options);
response5 = jsondecode(response5);
outputReport(response5, ...
             'Example 5 assembling HED with extra columns for events.');
if ~isempty(response5.error_type) || ...
   ~strcmpi(response5.results.msg_category, 'success')
   errors{end + 1} = ...
       'Example 5 failed to assemble file with extra columns.';
end

%%  Example 6: Generate a sidecar template from an events file.
request6 = struct('service', 'events_generate_sidecar', ...
                  'events_string', data.eventsText);
request6.columns_categorical = {'event_type', 'face_type', 'rep_status'};
request6.columns_value = {'trial', 'rep_lag', 'stim_file'};
response6 = webwrite(servicesUrl, request6, options);
response6 = jsondecode(response6);
outputReport(response6, ...
    'Example 6 generate a sidecar from an event file.');
if ~isempty(response6.error_type) || ...
   ~strcmpi(response6.results.msg_category, 'success')
   errors{end + 1} = 'Example 6 failed to generate a sidecar correctly.';
end
